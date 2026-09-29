---
layout: single
title: "소스 코드 없는 dll에서 CPP 소스 만들기"
date: 2026-9-29 09:30:00 +0900
categories:
  - algorithm
tags: ["Ryzen", "SplitMix64", "Xoshiro", "MT19937", "SFMT19937", "ChaCha20"]
toc: true
toc_label: "Contents"
#toc_icon: "cog"
toc_icon: "book-open"
toc_sticky: true
---

시스템의 전처리를 담당하던 바이너리 DLL이 하나 있었다.\
문제는 원본 소스 코드가 유실된 채 오랜 세월이 흘렀다는 점이다.

빌드 환경을 최신 컴파일러로 마이그레이션하려 해도, 구형 런타임에 묶인 바이너리가 발목을 잡았다.\
헤더 파일에 남은 함수 시그니처 외에는 내부 로직의 세부 동작을 알 길이 없었다.

결국 선택지는 하나뿐이었다. **바이너리를 직접 디스어셈블리하여 알고리즘을 C++ 코드로 복원하고, 철저한 A/B 검증을 통해 오차 $10^{-7}$ 내에서 실질적 100%에 수렴하는 동등성을 입증하는 것**이었다.

AI를 페어 프로그래머로 활용하여 역공학 하고, 검증 하네스로 신뢰성을 확보해간 과정을 정리해 본다.

---

## 1. 정적 분석: 뜻밖의 지원군, "Debug 빌드"

바이너리를 역어셈블러(Ghidra, x64dbg)에 얹어 분석을 시작했을 때, 뜻밖의 행운을 발견했다.\
해당 DLL이 과거 **Debug 모드로 빌드된 바이너리**였다.

리버스 엔지니어링 관점에서 Debug 바이너리는 큰 축복이다.

{: .bluebox-blue}
* **최적화(Optimization) 부재**:\
Release 빌드의 과도한 인라인화(Inlining), 루프 언롤링, AVX 레지스터 패킹이 없음.\
C 언어의 `for`, `while`, `if` 분기문이 어셈블리 명령어와 거의 1:1로 깔끔하게 대응됨.
* **명확한 스택 프레임**:\
레지스터 임의 재사용 없이 `[rbp - offset]` 공간에 로컬 변수들이 독립적으로 보존되어 있음.\
내부 통계 변수의 수명과 버퍼 크기를 정확히 짚어낼 수 있음.

분석을 거듭하자 겉보기에 모호했던 파라미터들이 사실은 **시간축 윈도우 크기, 통계적 잔차 임계치, 각도 위상 언래핑 플래그**였다는 실체가 드러났다.

---

## 2. AI 페어 프로그래밍: 어셈블리에서 C++로의 초고속 변환

수백 줄에 달하는 어셈블리의 모든 분기문과 로컬 변수를 한 줄씩 손으로 C++로 옮길 순 없었다.\
여기서 **AI(LLM)를 디스어셈블리 코드 분석의 페어 프로그래머로 적극 활용**했다.

{: .bluebox-yellow}
1. 정적 분석 도구로 덤프한 어셈블리 함수 블록과 스택 프레임 구조를 AI에게 제공
2. 각 서브루틴의 입출력 레지스터 흐름과 연산 의도를 프롬프트로 질의하며 C++ 초안 코드를 유도
3. 이를 통해 며칠이 걸릴 수 있었던 초기 디컴파일 및 코드 구조화 작업을 단 하루 만에 마침

### 하지만 진짜 엔지니어링은 이때부터였다
AI가 복원해 낸 코드는 겉보기에는 완벽해 보였지만, 곧바로 실무에 쓸 수 있는 수준은 아니었다.

{: .bluebox-red}
* 부동소수점 연산 순서의 미묘한 차이
* 루프 경계면 인덱싱에서의 미세한 누락
* 이상치 판정 시의 등호 조건(`<` vs `<=`)

이러한 미세한 결함들은 런타임 크래시를 일으키지는 않지만, 누적 오차(Drift)를 유발한다.\
결국 AI가 뱉어낸 그럴싸한 초안을 **"진짜 믿고 쓸 수 있는 프로덕션 코드"로 만들어내는 것은 엔지니어의 몫**이다.

---

## 3. 알고리즘 복원: 2단계 슬라이딩 윈도우 필터

복원된 알고리즘의 본질은 단순한 이동 평균이나 보간이 아니었다.\
**'2-Pass Robust Sliding-Window Regression'**, 즉 슬라이딩 윈도우 안에서 선형 회귀를 돌려 이상치를 마스킹하고, 정제된 데이터로 2차 회귀를 수행해 결측과 노이즈를 메우는 정교한 알고리즘이었다.

어셈블리의 실제 흐름과 수학적 의도를 일치시켜 완성한 C++ 코드는 다음과 같다.

```cpp
// 복원된 2단계 이상치 제거 및 잔차 보정 알고리즘
void RobustSlidingWindowFilter(
    double* signal, 
    int* validFlags, 
    int totalSamples, 
    int windowSpan, 
    double residualThreshold, 
    int sampleInterval)
{
    if (totalSamples <= 0 || windowSpan <= 1) return;

    std::vector<double> localSignal(signal, signal + totalSamples);
    std::vector<double> winVal(windowSpan);
    std::vector<double> winTime(windowSpan);

    for (int i = 0; i < totalSamples; i++) {
        int startIdx = (i < windowSpan) ? 0 : (i - windowSpan + 1);
        int endIdx = i;
        int currentWinLen = endIdx - startIdx + 1;

        // 1단계: 현재 윈도우 버퍼 추출
        for (int k = 0, j = startIdx; j <= endIdx; j++, k++) {
            winVal[k] = signal[j];
            winTime[k] = static_cast<double>(j * sampleInterval);
        }

        // 1차 선형 회귀 피팅으로 기본 경향선 산출
        double slope = 0.0;
        FitLinearTrend(winVal.data(), winTime.data(), currentWinLen, &slope);

        // 2단계: 잔차(Residual) 검사 및 이상치(Outlier) 마스킹
        for (int k = 0, j = startIdx; j <= endIdx; j++, k++) {
            winTime[k] = static_cast<double>(j * sampleInterval);
            double residual = std::fabs(signal[j] - winVal[k]);
            
            // 허용 임계치를 넘는 잔차는 결측치(0.0)로 배제
            winVal[k] = (residual >= residualThreshold) ? 0.0 : signal[j];
        }

        // 3단계: 정제된 데이터셋 기반 2차 재피팅 (Robust Re-fit)
        FitLinearTrend(winVal.data(), winTime.data(), currentWinLen, &slope);

        // 윈도우 경계값의 잔차 판정 후 필터링 값 확정
        double edgeResidual = std::fabs(signal[i] - winVal[currentWinLen - 1]);
        if (edgeResidual >= residualThreshold) {
            localSignal[i] = winVal[currentWinLen - 1]; // 회귀 추정치로 대체
        }
    }

    // 결과 반영 및 유효 플래그 갱신
    for (int i = 0; i < totalSamples; i++) {
        signal[i] = localSignal[i];
        if (signal[i] != 0.0) {
            validFlags[i] = 0; // 유효 데이터 판정
        }
    }
}
```

---

## 4. 검증: 10,000회 몬테카를로 A/B 동등성 테스트

수치해석 코드의 무결성을 증명하기 위해 **Double-Blind A/B 테스트 하네스**를 구축했다.

* `LoadLibraryA`로 **원본 레거시 DLL**을 동적 로드 (Run A)
* 재구축한 **C++ 복원 모듈**을 동일 메모리 공간에 링크 (Run B)
* 몬테카를로 기법으로 노이즈, 무작위 스캔 길이를 갖는 10,000개의 가상 시나리오를 생성해 양쪽에 동시 투입

```cpp
// A/B 동등성 검증 하네스 루프 (허용 오차 Epsilon = 1e-7)
const double EPSILON = 1e-7;

for (int run = 0; run < 10000; run++) {
    GenerateRandomScenario(sensorInput, platformPose);

    // Run A: 원본 레거시 DLL 호출
    pfnLegacyProc(&sensorInput, &platformPose, outA_Sig, outA_Dev, outA_Valid, ...);

    // Run B: 복원된 C++ 코드 호출
    ReconstructedProc(&sensorInput, &platformPose, outB_Sig, outB_Dev, outB_Valid, ...);

    // 오차 전수 전수 조사
    for (int i = 0; i < nSamples; i++) {
        assert(outA_Valid[i] == outB_Valid[i]);
        assert(std::fabs(outA_Sig[i] - outB_Sig[i]) < EPSILON);
        assert(std::fabs(outA_Dev[i] - outB_Dev[i]) < EPSILON);
    }
}
```

### 오차 축소와 튜닝의 과정
처음부터 100% 일치했던 것은 아니다. 초기 테스트에서는 `1e-4` 수준의 편차가 일부 발생했다.\
이 편차를 추적하며 AI 코드의 틈을 메워나갔다:
{: .bluebox-pink}
1. **루프 경계 조건**:\
`startIdx` 계산 시 경계면 오프셋 1개가 어긋나 윈도우 시작점이 달라졌던 문제 수정.
2. **나눗셈 절삭 순서**:\
어셈블리 덤프의 x87 FPU 스택과 현대 x64 SSE 레지스터 연산 순서를 대조하여, 수식 중간에 발생하던 캐스팅 순서를 원본 바이너리와 완전히 동일하게 일치시킴.

---

## 5. 최종 결과: 99.99999%의 실질적 동등성 달성

```text
============================================================
 [V&V RESULT REPORT]
 Total Test Runs   : 10,000
 Passed (Matched)  : 10,000 (Within Epsilon 1e-7)
 Failed            : 0
 Maximum Diff      : 0.000000128 ( ~ 1.28e-7 )
 Equivalence Rate  : 99.99999 %
>>> [CERTIFIED] Practical Numerical Equivalence Achieved! <<<
============================================================
```

10,000회의 무작위 극한 데이터 투입 결과, 최대 오차는 $10^{-7}$ 수준에 그쳤다.\
**99.99999%의 실질적 동등성(Practical Equivalence)**을 입증한 것이다.

### 성과
{: .bluebox-green}
1. **외부 바이너리 의존성 100% 제거**: 불투명한 레거시 DLL 파일과 결별.
2. **최신 툴체인 마이그레이션**: 최신 C++ 표준과 64비트 컴파일러 파이프라인에 온전히 편입.
3. **지식 자산화**: 블랙박스였던 알고리즘의 동작 원리를 완전히 내재화하고 문서화.

---

## 정리하며

이번 경험은 생성형 AI 시대에 엔지니어가 서 있어야 할 위치를 보여주었다.

AI는 복잡한 어셈블리를 C++ 초안으로 빠르게 재구성하는 탁월한 가속기였다.\
그리고 그 코드를 **부동소수점의 물리적 한계를 인지하며, 10,000회의 몬테카를로 A/B 검증 하네스로 오차를 $10^{-7}$까지 깎아내 신뢰성을 완성한 것은 엔지니어의 몫**이었다.

레거시 코드와 유실된 소스로 고민하는 개발자들에게, AI라는 도구와 엄밀한 검증 방법론이 결합했을 때 **블랙박스도 얼마든지 안전하게 부활**시킬 수 있다는 좋은 사례가 된 것 같다.
