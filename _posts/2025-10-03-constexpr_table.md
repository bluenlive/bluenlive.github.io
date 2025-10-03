---
layout: single
title: "LUT 테이블을 constexpr로 생성해서 최적화하기"
date: 2025-10-03 18:39:00 +0900
categories:
  - algorithm
---

## Spline64 보간법의 테이블 생성

데이터를 변환하기 위해 LUT(Look-Up Table) 테이블을 사용할 수 있다.\
이 테이블은 미리 계산된 값을 저장하여, 런타임에 반복적인 계산을 피할 수 있게 해준다.

Spline64 보간법을 적용하여 이미지 처리를 할 때도 LUT 테이블을 사용할 수 있다.

```cpp
constexpr static float spline64filter(const float v) noexcept {
    if (v < 1.0f)
        return ((49.0f / 41.0f * (v) - 6387.0f / 2911.0f) * (v) - 3.0f / 2911.0f) * (v) + 1.0f;
    else if (v < 2.0f)
        return ((-24.0f / 41.0f * (v - 1.0f) + 4032.0f / 2911.0f) * (v - 1.0f) - 2328.0f / 2911.0f) * (v - 1.0f);
    else if (v < 3.0f)
        return ((6.0f / 41.0f * (v - 2.0f) - 1008.0f / 2911.0f) * (v - 2.0f) + 582.0f / 2911.0f) * (v - 2.0f);
    else if (v < 4.0f)
        return ((-1.0f / 41.0f * (v - 3.0f) + 168.0f / 2911.0f) * (v - 3.0f) - 97.0f / 2911.0f) * (v - 3.0f);
    else
        return 0.0f;
}

constexpr int nResolutionSpline{ 512 };
constexpr float nInvResolutionSpline{ 1.0f / nResolutionSpline };

const static std::vector<float> vTableSpline64(4 * nResolutionSpline + 1);
const float* tableSpline64{ &(vTableSpline64[0]) };
static bool bTableS64_isset{ false };

static void SetSpline64Table() {
    if (!bTableS64_isset) {
        for (int i = 0; i < 4 * nResolutionSpline + 1; ++i)
            ((float*)tableSpline64)[i] = spline64filter(i * nInvResolutionSpline);
    }

    bTableS64_isset = true;
}
```

위와 같이 테이블을 생성하면 한 번만 테이블을 생성하고, 이후에는 테이블을 재활용할 수 있다.

## constexpr로 테이블 생성 최적화

테이블을 런타임에 생성하는 대신, 컴파일 타임에 생성할 수 있다면 더 효율적으로 테이블을 사용할 수 있다.

또한, 위와 같이 구현하면 엄밀하게는 thread-safe하지 않다.\
즉, `bTableS64_isset` 변수를 여러 스레드가 동시에 접근할 때 문제가 발생할 수 있어 세심한 처리가 필요하다.

```cpp
constexpr int nResolutionSpline{ 512 };
constexpr float nInvResolutionSpline{ 1.0f / nResolutionSpline };

static constexpr float spline64filter(const float v) noexcept {
    if (v < 1.0f)
        return ((49.0f / 41 * (v) - 6387.0f / 2911) * (v) - 3.0f / 2911) * (v) + 1;
    else if (v < 2.0f)
        return ((-24.0f / 41 * (v - 1) + 4032.0f / 2911) * (v - 1) - 2328.0f / 2911) * (v - 1);
    else if (v < 3.0f)
        return ((6.0f / 41 * (v - 2) - 1008.0f / 2911) * (v - 2) + 582.0f / 2911) * (v - 2);
    else if (v < 4.0f)
        return ((-1.0f / 41 * (v - 3) + 168.0f / 2911) * (v - 3) - 97.0f / 2911) * (v - 3);
    return 0.0f;
}

constexpr static auto makeSpline64Table() {
    std::array<float, 4 * nResolutionSpline + 1> arr{};
    for (int i = 0; i <= 4 * nResolutionSpline; ++i)
        arr[i] = spline64filter(i * nInvResolutionSpline);
    return arr;
}
constexpr static auto tableSpline64 = makeSpline64Table();
```

위와 같이 `constexpr`를 사용하여 테이블을 컴파일 타임에 생성할 수 있다.\
이렇게 하면 런타임에 테이블을 생성하는 오버헤드를 피할 수 있고, 스레드 안전성 문제도 해결된다.

또한, `std::array`를 사용하여 고정 크기의 배열을 생성하므로, 메모리 관리도 더 효율적으로 할 수 있다.

## 응용1. Lanczos

이렇게 컴파일 타임에 테이블을 생성하는 방법은 다른 보간법에도 적용할 수 있다.

그런데, Lanczos 보간법의 경우에 이를 적용하려면 고민이 필요하다.\
Lanczos 보간법은 `sinc` 함수를 사용하는데, 이 함수는 `sin()`을 포함한다.\
그리고, `sin()` 함수는 Visual Studio 2022에서는 `constexpr`로 사용할 수 없다.\
(C++20 표준에서는 `constexpr`로 사용할 수 있지만, 컴파일러가 이를 지원하지 않는 경우가 있다.)

이럴 때는 Horhner's method를 사용하여 `sinc` 함수를 다항식으로 근사해서 적용할 수 있다.

```cpp
constexpr float horner_sin(float x) noexcept {
    constexpr float PI_F = 3.14159265358979323846f;
    constexpr float TWO_PI_F = 6.28318530717958647692f;

    // --- 범위 축소: [-π, π] ---
    while (x > PI_F)  x -= TWO_PI_F;
    while (x < -PI_F)  x += TWO_PI_F;

    const float x2 = x * x;

    // Horner’s method, 13차까지 포함
    // sin(x) ≈ x * (1 - x²/6 + x⁴/120 - x⁶/5040 + x⁸/362880 - x¹⁰/39916800 + x¹²/6227020800)
    constexpr float C1 = 1.0f / 6227020800.0f;
    constexpr float C2 = -1.0f / 39916800.0f;
    constexpr float C3 = 1.0f / 362880.0f;
    constexpr float C4 = -1.0f / 5040.0f;
    constexpr float C5 = 1.0f / 120.0f;
    constexpr float C6 = -1.0f / 6.0f;

    return x * ((((((C1 * x2 + C2) * x2 + C3) * x2 + C4) * x2 + C5) * x2 + C6) * x2 + 1.0f);
}

constexpr static auto makeLanczosTable() {
    std::array<float, (int)LANCZOS_RADIUS * nSamplingResolution + 1> arr{};
    constexpr float step{ nInvSamplingResolution * PI_F };
    constexpr float invRadius{ 1.0f / LANCZOS_RADIUS };

    arr[0] = 1.0f;
    for (int i = 1; i <= (int)LANCZOS_RADIUS * nSamplingResolution; ++i) {
        const float pi_i = i * step;
        const float s1 = horner_sin(pi_i);
        const float s2 = horner_sin(pi_i * invRadius);
        const float inv_denom = 1.0f / (pi_i * pi_i);
        arr[i] = (LANCZOS_RADIUS * s1 * s2) * inv_denom;
    }
    return arr;
}
constexpr static auto tableLanczos = makeLanczosTable();
```

## 응용2. sRGB to Linear

sRGB 색 공간에서 Linear 색 공간으로 변환할 때도 LUT 테이블을 사용할 수 있다.\
sRGB to Linear 변환 공식은 다음과 같다.

$$Linear = \left\{ \begin{array}{cl}
\frac {S}{12.92} & : \ 0 \leq S \leq 0.04045 \\
\left ( \frac {S + 0.055}{1.055} \right ) ^{2.4} & : \ 0.04045 \lt S \leq 1
\end{array} \right.$$

`pow()` 함수 역시 Visual Studio 2022에서는 `constexpr`로 사용할 수 없다.\
따라서, 이를 다항식으로 근사해야 테이블을 생성할 수 있다.

```cpp
// 5제곱근 (뉴턴-랩슨)
constexpr float static fifth_root(float a, int iterations = 12) {
    if (a <= 0.0f) return 0.0f;
    float x = 1.0f;
    for (int i = 0; i < iterations; ++i) {
        // f(x) = x^5 - a → f'(x) = 5x^4
        x = (4.0f * x + a / (x * x * x * x)) / 5.0f;
    }
    return x;
}

// -------------------- sRGB → Linear --------------------
// x^2.4 = (x^2) * ( (x^2)^(1/5) )
constexpr static float pow_2_4(float x) {
    float x2 = x * x;
    return x2 * fifth_root(x2);
}

constexpr static float sRGBToLinear(float c) {
    return (c <= 0.04045f)
        ? (c / 12.92f)
        : pow_2_4((c + 0.055f) / 1.055f);
}

constexpr static auto makeSRGB2LinearLUT() {
    std::array<float, 256> arr{};
    for (int i = 0; i < 256; ++i) {
        float c = static_cast<float>(i) / 255.0f;
        arr[i] = sRGBToLinear(c);
    }
    return arr;
}
constexpr static auto tableSRGB2Linear = makeSRGB2LinearLUT();
```
