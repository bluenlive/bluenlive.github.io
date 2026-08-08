---
layout: single
title: "난수 변환꞉ 모듈로 편향 없는 정수 변환 및 고속 실수 정규화"
date: 2026-8-8 17:46:00 +0900
categories:
  - algorithm
toc: true
toc_label: "Contents"
#toc_icon: "cog"
toc_icon: "book-open"
toc_sticky: true
---

## 들어가기에 앞서

[이전 글 1](/algorithm/fastest_normal_randoms/), [이전 글 2](/algorithm/fastest_uniform_randoms/)에서 난수를 빠르게 생성하는 방법을 기술했었다.\
이렇게 생성된 난수는 32비트 또는 64비트 전체 영역을 차지한다.

이를 실제로 사용하려면 특정 범위의 정수 `[0, N)`나 실수 `[0.0, 1.0)`로 변환해야 한다.\
이 과정에서 나머지 연산(`%`)이나 나눗셈을 사용할 때 발생하는 문제점과, 이를 효율적으로 해결하는 기법들을 정리한다.

---

## 1. 정수 범위 변환 `[0, N)`

### 1-1. 고전적 나머지 연산 (`x % N`)

가장 직관적인 방법은 난수를 `N`으로 나누어 **나머지**를 취하는 것이다.

{: .bluebox-blue}
* **장점**: 구현이 매우 단순하고 코드 직관성이 높음
* **단점**:
  * **모듈로 편향(Modulo Bias)**:\
$$2^{32}$$가 `N`으로 나누어떨어지지 않으면 앞쪽 숫자들이 뽑힐 확률이 미세하게 높아짐
  * **속도 저하**:\
CPU 연산 중 상대적으로 느린 나눗셈을 매번 실행함

---

### 1-2. Lemire FastRange (고속 비례 곱셈)

64비트 곱셈 후 비트 시프트 연산으로 나눗셈을 대체하는 방식이다.

```cpp
#include <cstdint>

// [0, N) 범위로 고속 변환
inline uint32_t FastRange(uint32_t x, uint32_t N)
{
    return static_cast<uint32_t>((static_cast<uint64_t>(x) * N) >> 32);
}
```

{: .bluebox-blue}
* **장점**: 나눗셈 대신 1클럭 수준의 곱셈과 시프트 연산만 사용하여 고속 연산 가능
* **단점**: **모듈로 편향**이 여전히 존재하므로 엄격한 무작위성이 필요한 곳에는 부적합
* **적용**: 게임, 그래픽스 등 극상의 속도가 최우선인 환경

---

### 1-3. Lemire FastRangeDebiased (편향 차단)

**다니엘 레미어** 교수가 제안한 방식으로, **편향이 발생하는 영역을 감지하여 재추출**한다.

$$2^{32}$$개의 정수를 $$N$$개 구간으로 나눌 때, $$2^{32}$$가 $$N$$의 배수가 아니면 $$2^{32} \pmod N$$ 만큼의 남는 영역이 생긴다.\
이게 편향을 만들며, 이 영역의 크기를 계산한 것이 `threshold`이다.

$$threshold = 2^{32} \pmod N = \left(-N \right) \bmod N$$

**하위 32비트(`leftover`)**는 다음과 같이 적을 수 있다.

$$leftover = x \times N \pmod{2^{32}}$$

레미어 교수가 증명한 것은 $$leftover < threshold$$일 때만 비례 균등성이 깨진다는 것이다.\
즉, 이 때만 난수를 재추출하면 된다.

그런데, 이렇게 매번 나머지 연산(나눗셈)을 수행하면 연산 속도에 악영향을 미친다.\
따라서, 살짝의 아이디어를 가미한다.\
$$threshold < N$$이므로 $$leftover < N$$일 때만 확인하면 된다.

```cpp
#include <cstdint>

template <typename Rng>
uint32_t FastRangeDebiased(Rng& rng, uint32_t N)
{
    uint64_t multi = static_cast<uint64_t>(rng()) * N;
    uint32_t leftover = static_cast<uint32_t>(multi);

    // 99.99% 확률로 아래 조건문은 거짓이 되어 나눗셈 없이 통과함
    if (leftover < N) {
        uint32_t threshold = -N % N; // (2^32 - N) % N
        while (leftover < threshold) {
            multi = static_cast<uint64_t>(rng()) * N;
            leftover = static_cast<uint32_t>(multi);
        }
    }
    return static_cast<uint32_t>(multi >> 32);
}
```

{: .bluebox-blue}
* **장점**:
  * 모듈로 편향을 수학적으로 완전히 차단
  * 조건문 지연 계산(Lazy Evaluation) 덕분에 $$99.99\%$$ 확률로 나눗셈 없이 곱셈 1회만으로 처리됨
* **단점**: 극히 드문 확률로 재추출 루프가 돌 수 있어 소요 시간이 가변적임

---

## 2. 실수 범위 변환 `[0.0, 1.0)`

### 2-1. C++ 표준 방식 (`std::generate_canonical`)

C++11 표준 라이브러리가 제공하는 범용 실수 변환 함수다.

```cpp
#include <random>
#include <cstdint>
#include <limits>

// URBG 규격을 만족하는 최소 구성 요소는 다음과 같음
// state를 제외한 4가지가 반드시 있어야 함
struct MinimalUrbg
{
    using result_type = uint32_t;
    static constexpr result_type min() { return 0; }
    static constexpr result_type max() { return std::numeric_limits<result_type>::max(); }

    uint32_t state = 12345;
    result_type operator()() { return state += 0x9E3779B9U; }
};

void SampleCanonical()
{
    MinimalUrbg rng;

    // float: 24비트 가수부 채움
    float f = std::generate_canonical<float, 24>(rng);

    // double: 53비트 가수부를 채우기 위해 rng()를 자동으로 2회 호출함
    double d = std::generate_canonical<double, 53>(rng);
}

```

{: .bluebox-blue}
* **장점**:
  * URBG 인터페이스만 갖추면 커스텀 엔진에서도 표준 기능을 그대로 사용 가능
  * 엔진의 단일 출력 비트가 적어도 필요한 비트 수만큼 연속 호출하여 정밀도를 맞춰줌
  * `1.0` 경계값 도달 오류를 표준 차원에서 예방함
* **단점**: 루프와 나눗셈 연산이 포함되어 단일 비트 연산 방식보다 상대적으로 느림

---

### 2-2. 비트 잘라내기 후 비례 곱셈 (Fast & Exact)

IEEE 754 가수부(Mantissa) 비트 수에 맞추어 난수를 시프트한 뒤, 해당 가짓수의 역수를 곱한다.

```cpp
#include <cstdint>

// 32비트 -> float (상위 24비트 활용)
inline float ToFloat24(uint32_t x)
{
    return (x >> 8) * 0x1.0p-24f;
}

// 64비트 -> double (상위 53비트 활용)
inline double ToDouble53(uint64_t x)
{
    return (x >> 11) * 0x1.0p-53;
}

// 32비트 -> double (32비트 엔트로피 100% 보존)
inline double ToDouble32(uint32_t x)
{
    return x * 0x1.0p-32;
}

```

{: .bluebox-blue}
* **장점**:
  * 반올림으로 인해 상한선 `1.0`에 도달하는 경계 오차가 발생하지 않음
  * `32비트 -> double` 변환은 비트 손실 없이 1회 난수 생성만으로 약 $$42.9$$억 단계의 실수 해상도를 제공함
* **단점**: 지수 표현식 리터럴(`0x1.0p-24f`) 등 비트 구조에 대한 사전 이해가 필요함

여기서 **32비트 → double**은 눈여겨볼만 한 지점이 있다.

{: .bluebox-green}
* 32비트 → float 변환의 경우 실수 간의 간격이 $$\frac{1}{2^{24}} \approx 5.96 \times 10^{-8}$$ 임
* 64비트 → double 변환의 경우 실수 간의 간격이 $$\frac{1}{2^{53}} \approx 1.11 \times 10^{-16}$$ 임
* 32비트 → double 변환의 경우 실수 간의 간격이 $$\frac{1}{2^{32}} \approx 2.33 \times 10^{-10}$$ 임

double의 해상도(약 **9천조** 개)를 모두 사용하진 못해도 상당한 고해상도(약 **42.9억** 개)의 난수를 사용할 수 있는 것이다.

---

### 2-3. IEEE 754 비트 직접 주입 기법 (C++20)

`[1.0, 2.0)` 실수 영역에 무작위 비트를 직접 주입한 후 `1.0`을 빼는 방식이다.

```cpp
#include <cstdint>
#include <bit>

// 32비트 -> float 변환
inline float BitHackToFloat(uint32_t x)
{
    uint32_t bits = 0x3F800000U | (x >> 9);
    return std::bit_cast<float>(bits) - 1.0f;
}

// 64비트 -> double 변환
inline double BitHackToDouble(uint64_t x)
{
    uint64_t bits = 0x3FF0000000000000ULL | (x >> 12);
    return std::bit_cast<double>(bits) - 1.0;
}

// 32비트 -> double 변환
inline double BitHackToDouble(uint32_t x)
{
    // 32비트 난수를 double의 52비트 가수부 상위 영역(비트 51~20)에 배치
    uint64_t bits = 0x3FF0000000000000ULL | (static_cast<uint64_t>(x) << 20);
    return std::bit_cast<double>(bits) - 1.0;
}
```

{: .bluebox-blue}
* **장점**:
  * 곱셈이나 나눗셈 없이 비트 연산(`OR`)과 뺄셈(`SUB`)만 수행하므로 매우 빠름
  * 수학적으로 `1.0` 경계값 오류가 발생하지 않음
* **단점**: IEEE 754 비트 구조 규격에 직접 의존함

---

## 정리

정수 범위 변환 시 속도와 편향 차단을 동시에 달성하려면 **Lemire FastRangeDebiased**가 훌륭한 선택이다.\
실수 변환 시 범용성과 규격 안전성을 위해서는 **`std::generate_canonical`**을 사용한다.\
하지만, 속도가 최우선인 환경에서는 **비례 곱셈 기법**이나 **비트 직접 주입 기법**이 매우 유용하다.
