---
layout: single
title: "Windows 고정밀 Sleep 구현기꞉ 정밀도와 CPU 점유율의 딜레마"
date: 2026-9-29 00:20:00 +0900
categories:
  - algorithm
tags: ["Ryzen", "SplitMix64", "Xoshiro", "MT19937", "SFMT19937", "ChaCha20"]
toc: true
toc_label: "Contents"
#toc_icon: "cog"
toc_icon: "book-open"
toc_sticky: true
---

Windows 환경에서 밀리초(ms) 이하의 정밀한 주기 제어를 구현하는 일은 생각보다 까다롭다.\
기본 API의 제약부터 STL의 실체, 그리고 시스템 부하 없이 마이크로초 단위 오차를 잡는 대안까지 정리해 본다.

---

## 1. Sleep()의 태생적 한계

Windows의 기본 클럭 인터럽트 주기는 **약 15.625ms(초당 64회)**다.

`::Sleep(1)`이나 `::Sleep(10)`을 호출해도 스레드는 요청한 시간에 맞춰 깨어나지 못한다.\
OS의 15.625ms 틱 경계에 도달해야만 대기 큐에서 스케줄러로 복귀하기 때문이다.

과거에는 `timeBeginPeriod(1)`을 호출해 인터럽트 주기를 1ms로 강제 끌어올려 해결하곤 했다.\
하지만 이는 개별 프로세스를 넘어 **시스템 전역**에 영향을 미친다.\
백그라운드 전체의 인터럽트 빈도를 증가시켜 불필요한 컨텍스트 스위칭, 전력 소모, 발열을 유발한다.\
최신 Windows **환경**에서는 지양해야 할 구시대적 방식이다.

---

## 2. STL(std::this_thread::sleep_for)은 대안이 될 수 있는가?

C++11 이후 모던 C++이 제공하는 `std::this_thread::sleep_for`를 대안으로 떠올리기 쉽다.\
표준 라이브러리인 만큼 내부적으로 정교한 처리가 되어 있을 것으로 기대한다.

하지만 MSVC STL의 내부 구현을 추적해 보면 실상은 단순한 래퍼다.

{: .bluebox-blue}
* `sleep_for()`는 내부 런타임 함수인 `_Thrd_sleep()`을 호출
* 이는 곧바로 Windows API인 `SleepEx()` 또는 `NtDelayExecution()` 시스템 콜로 이어짐

결국 Win32 `::Sleep()`과 100% 동일한 커널 경로를 거친다.\
플랫폼 독립성을 위한 추상화 계층일 뿐인 것이다.\
Windows 네이티브 환경에서는 코드 길이만 늘어날 뿐 **정밀도 상의 이득은 전혀 없다**.

---

## 3. 그럼 진짜 대안은 무엇인가?

전역 타이머 설정을 왜곡하지 않으면서 정밀도를 확보하는 현실적인 대안은 두 가지다.

### ① Spin-Yield (협력적 양보 + 미세 스핀)

QPC(QueryPerformanceCounter)로 하드웨어 누적 틱을 추적한다.\
남은 대기 시간이 넉넉할 때(2ms 초과)는 `SwitchToThread()`로 타 스레드에 양보한다.\
그러다, 마지막 2ms 구간에서만 스핀 루프를 돌며 시간을 맞춘다.

```cpp
void DoSpinYieldSleep(double milliseconds)
{
    if (milliseconds <= 0.0) return;

    static const LARGE_INTEGER freq = []() {
        LARGE_INTEGER f;
        QueryPerformanceFrequency(&f);
        return f;
    }();

    LARGE_INTEGER start, current;
    QueryPerformanceCounter(&start);

    const LONGLONG targetTicks = start.QuadPart + static_cast<LONGLONG>((milliseconds * freq.QuadPart) / 1000.0);
    const LONGLONG yieldThreshold = (freq.QuadPart * 2) / 1000; // 2.0ms

    while (true) {
        QueryPerformanceCounter(&current);
        const LONGLONG remainingTicks = targetTicks - current.QuadPart;
        if (remainingTicks <= 0) break;

        if (remainingTicks > yieldThreshold) {
            SwitchToThread();
        } else {
            YieldProcessor();
        }
    }
}
```

### ② Hybrid Sleep (고해상도 커널 대기 + 마이크로 스핀)

Windows 10 1803부터 지원되는 `CREATE_WAITABLE_TIMER_HIGH_RESOLUTION`을 활용한다.\
전역 부작용이 없는 프로세스 로컬 고해상도 커널 타이머다.

대기 시간 대부분은 커널 타이머(`WaitForSingleObject`)로 코어를 완전히 비운 채 잠든다.\
만료 직후 남은 0.5~1.0ms는 `SwitchToThread()`로 가볍게 양보한다.\
그러다, 마지막 0.5ms 미만 구간만 `_mm_pause()`로 시간을 맞춘다.

```cpp
void DoHybridSleep(double milliseconds)
{
    if (milliseconds <= 0.0) return;

    static const LARGE_INTEGER freq = []() {
        LARGE_INTEGER f;
        QueryPerformanceFrequency(&f);
        return f;
    }();

    struct ThreadTimer {
        HANDLE hTimer{ NULL };
        bool isHighRes{ false };

        ThreadTimer() {
            hTimer = CreateWaitableTimerExW(NULL, NULL, CREATE_WAITABLE_TIMER_HIGH_RESOLUTION, TIMER_ALL_ACCESS);
            if (hTimer) {
                isHighRes = true;
            } else {
                hTimer = CreateWaitableTimerW(NULL, FALSE, NULL);
            }
        }
        ~ThreadTimer() {
            if (hTimer) CloseHandle(hTimer);
        }
    };
    thread_local ThreadTimer timer;

    LARGE_INTEGER start;
    QueryPerformanceCounter(&start);
    const LONGLONG targetTicks = start.QuadPart + static_cast<LONGLONG>((milliseconds * freq.QuadPart) / 1000.0);

    // 1단계: 커널 타이머 절전 대기
    const double marginMs = timer.isHighRes ? 1.0 : 16.0;
    if (timer.hTimer && milliseconds > (marginMs + 0.5)) {
        LARGE_INTEGER dueTime;
        dueTime.QuadPart = -static_cast<LONGLONG>((milliseconds - marginMs) * 10000.0); // 100ns 단위
        if (SetWaitableTimer(timer.hTimer, &dueTime, 0, NULL, NULL, FALSE)) {
            WaitForSingleObject(timer.hTimer, INFINITE);
        }
    }

    LARGE_INTEGER now;
    QueryPerformanceCounter(&now);

    // 2단계: 협력적 스레드 양보 (0.5ms 전까지)
    const LONGLONG yieldThreshold = freq.QuadPart / 2000; // 0.5ms
    while (targetTicks - now.QuadPart > yieldThreshold) {
        SwitchToThread();
        QueryPerformanceCounter(&now);
    }

    // 3단계: 하드웨어 미세 스핀 루프
    while (now.QuadPart < targetTicks) {
        _mm_pause();
        QueryPerformanceCounter(&now);
    }
}
```

---

## 4. 실제 구현 결과꞉ Sleep()과 STL은 정말 같은가?

동일한 시스템 환경에서 19.0ms 대기를 15회씩 반복 계측하여 네 가지 방식을 대조했다.

![image](/images/2026-09-29/sleeptester_B_okl_s36_Q.webp)
*단순해 보이지만 무려 4개의 퀑기술이…*

| 측정 항목 | Win32 Sleep() | STL sleep_for() | Spin-Yield | Hybrid Sleep |
| --- | --- | --- | --- | --- |
| **목표 시간** | 19.0000 ms | 19.0000 ms | 19.0000 ms | 19.0000 ms |
| **평균 경과 시간** | 25.5993 ms | 26.4612 ms | 19.0005 ms | 19.0015 ms |
| **표준편차 (Jitter)** | 2.4182 ms | 2.4368 ms | 0.0002 ms | 0.0012 ms |
| **스레드 CPU 시간** | 0.000 ms | 0.000 ms | 281.250 ms | 15.625 ms |

### 두 구현이 본질적으로 동일하다는 증거

{: .bluebox-pink}
1. **동일한 오버슛(Overshoot)꞉**\
19ms를 요구했음에도 둘 다 28ms 근처로 밀려남.\
OS 타이머 틱(당시 4.0ms)의 정수 배수로 양자화된 만료 지점에 동일하게 걸려든 결과.
2. **동일한 수준의 지터꞉**\
표준편차가 둘 다 2.4ms 안팎으로 튐.\
스케줄러 디스패치 지연과 전력 절감용 타이머 병합 등의 영향을 똑같이 받았음.
3. **0.000 ms의 순수 CPU 시간꞉**\
둘 다 스레드를 즉시 `Waiting` 큐로 넘겨 코어를 비움.

경과 시간, 편차 패턴, CPU 점유 방식 모두 완벽히 겹친다.\
STL의 `sleep_for()`가 Win32 `Sleep()` 계열 API의 껍데기에 불과함을 명백히 보여준다.

---

## 5. 최적의 대안꞉ '스레드 CPU 시간'의 진정한 의미

경과 시간 수치만 보면 Spin-Yield도 19.0005ms로 목표를 달성한다.\
하지만, 핵심 판별 기준은 스레드 CPU 시간(Thread CPU Time)이다.

스레드 CPU 시간은 물리적인 경과 시간이 아니다.\
해당 스레드가 실제 CPU 코어를 점유하고 기계어 연산을 수행한 순수 시간(User + Kernel Mode)을 뜻한다.

대기(Sleep)의 본질은 주기를 맞추는 동안 **CPU 코어를 비워 시스템 자원 소모를 최소화하는 것**이다.\
코어를 100% 점유한 채 바쁘게 헛도는 동작은 Sleep이라 부르기 어렵다[^1].

{: .bluebox-green}
* **Spin-Yield의 한계꞉**\
백그라운드 작업이 있는 일반 데스크톱에서는 `SwitchToThread()`가 동작해 CPU 시간이 31ms 수준으로 선방.\
하지만, 다른 프로세스가 없는 독립 전용 장비에서는 양보할 대상이 없음.\
즉시 리턴하면서 남은 17ms 구간까지 코어를 100% 태우게 됨.
* **Hybrid Sleep의 우위꞉**\
전체 대기 시간의 90% 이상을 커널 절전 대기 상태로 유지함.\
스레드 CPU 시간을 0ms에 가깝게 묶어두면서도 마지막 마이크로 스핀을 통해 오차를 1µs 단위로 억제.

전역 인터럽트 왜곡 없이 저전력 안정성과 마이크로초 단위의 정밀도를 동시에 달성하는 길은 **고해상도 WaitableTimer 기반의 Hybrid Sleep**이 가장 균형 잡힌 해법이다.

[^1]: 이거 그야말로 **자는 척**이랑 동일함
