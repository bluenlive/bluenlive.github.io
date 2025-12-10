---
layout: single
title: "퀘이크에 사용된 제곱근 함수의 위력"
date: 2025-12-10 10:58:00 +0900
categories:
  - algorithm
---

## 뉴턴-랩슨 방법으로 제곱근 계산

제곱근의 알고리즘을 얘기하려면 이 알고리즘을 먼저 얘기해야 한다.

{% capture algo0 %}

### 문제 설정

$$\sqrt{x}$$를 직접 함수로 두면 반복식에 제곱근이 계속 등장해 비효율적이므로, **근 찾기 문제**로 바꿔 접근한다.

$$
y^2 = x \quad \Rightarrow \quad f(y) = y^2 - x = 0
$$

### 뉴턴-랩슨 공식
뉴턴-랩슨 반복식은 다음과 같다.

$$
y_{n+1} = y_n - \frac{f(y_n)}{f'(y_n)}
$$

여기서
- $$f(y) = y^2 - x$$
- $$f'(y) = 2y$$

따라서,
$$
y_{n+1} = \frac{1}{2}\left(y_n + \frac{x}{y_n}\right)
$$

### $$\sqrt{2}$$ 계산

- 초기값 $$y_0 = 1$$
- 반복 계산:
  - $$y_1 = \tfrac{1}{2}(1 + 2/1) = 1.5$$
  - $$y_2 = \tfrac{1}{2}(1.5 + 2/1.5) \approx 1.4167$$
  - $$y_3 \approx 1.4142$$

빠르게 $$\sqrt{2} \approx 1.414213\cdots$$에 수렴한다.

이 방식은 놀랍게도 바빌로니아[^1]의 방식이나, 헤론의 방식[^2]과 사실상 일치한다.

{% endcapture %}
{% include bluenlive/algorithm.html content=algo0 %}

## 최신 CPU에 적용된 sqrt()

개발/운용 환경이 AMD나 인텔의 최신 CPU라면 뉴턴-랩스 법을 구현하는 건 큰 의미가 없다.\
이 환경에서는 정확도와 속도 모두 경이로운 수준이다.

간단한 테스트를 위해 아래 코드의 실행 결과를 보자.

```cpp
#include <cstdio>
#include <cmath>
#include <random>
#include <chrono>
#include <array>

using namespace std;

constexpr size_t test_count = 10000000;
constexpr int iter_count = 7;
array<double, test_count> test_values;
array<double, test_count> test_results;

void compare_square_root_quality()
{
    double sum = 0;
    double max_diff = 0;
    for (size_t i = 0; i < test_count; ++i)
    {
        const double diff = test_results[i] * test_results[i] - test_values[i];
        sum += diff * diff;
        if (sum > max_diff)
            max_diff = sum;
    }
    const double rmse = sqrt(sum / test_count);
    printf("RMSE: %.10f, max_diff: %.10f\n\n", rmse, max_diff);
}

int main()
{
    auto start = chrono::high_resolution_clock::now();

    static std::random_device rdev;
    static std::mt19937 gen(rdev());

    std::uniform_real_distribution<double> dist(0.0, 10.0);
    for (size_t i = 0; i < test_count; ++i)
        test_values[i] = dist(gen);

    auto stop = chrono::high_resolution_clock::now();
    auto duration = chrono::duration_cast<chrono::milliseconds>(stop - start);
    printf("Random number generation time: %lld ms\n", duration.count());
    printf("========================================\n\n");

    ////////////////////////////////////////////////
    // Standard sqrt

    start = chrono::high_resolution_clock::now();
    for (size_t i = 0; i < test_count; ++i)
        test_results[i] = sqrt(test_values[i]);
    stop = chrono::high_resolution_clock::now();
    duration = chrono::duration_cast<chrono::milliseconds>(stop - start);
    printf("Standard sqrt time: %lld ms\n", duration.count());
    compare_square_root_quality();
}
```

천만개의 난수의 제곱근을 구하는데 고작 **22ms**밖에 소요되지 않는다.\
그리고, 제곱근을 다시 제곱해서 **오차의 RMS**와 **오차의 최댓값**을 계산해도 아래와 같이 0에 가까운 수준이다.

```text
Random number generation time: 72 ms
========================================

Standard sqrt time: 22 ms
RMSE: 0.0000000000, max_diff: 0.0000000000
```

## sqrtf()

이후의 다른 알고리즘과 비교해보기 위해 `double`을 `float`로 변환해서 비슷한 작업을 해봤다.

```cpp
start = chrono::high_resolution_clock::now();
for (size_t i = 0; i < test_count; ++i)
{
    float x = static_cast<float>(test_values[i]);
    test_results[i] = static_cast<double>(sqrtf(x));
}
stop = chrono::high_resolution_clock::now();
duration = chrono::duration_cast<chrono::milliseconds>(stop - start);
printf("Standard sqrt (float) time: %lld ms\n", duration.count());
compare_square_root_quality();
```

float에서 생성한 난수가 아니라 double에서 생성한 난수를 float로 변환했다는 점에 유의.\
**시간은 경이로운 수준으로 적게 소요**됐고, 오차는 아래와 같다.

```text
Standard sqrt (float) time: 4 ms
RMSE: 0.0000003271, max_diff: 0.0000010700
```

## 뉴턴-랩슨 제곱근

뉴턴-랩슨 방법으로 제곱근을 계산하는 코드는 아래와 같다.

초기값은 1보다 큰 경우와 작은 경우로만 구분해서 부여했다.\
반복 횟수는 맨 앞의 코드에서 7로 통일해두었다.

반복 부분이 뉴턴-랩슨의 핵심 부분이다.

```cpp
start = chrono::high_resolution_clock::now();
for (size_t i = 0; i < test_count; ++i)
{
    double x = test_values[i];
    if (x == 0.0)
    {
        test_results[i] = 0.0;
        continue;
    }
    double guess = (x >= 1.0) ? x / 2.0 : (x + 1.0) * 0.5;
    for (int iter = 0; iter < iter_count; ++iter)
        guess = 0.5 * (guess + x / guess);
    test_results[i] = guess;
}
stop = chrono::high_resolution_clock::now();
duration = chrono::duration_cast<chrono::milliseconds>(stop - start);
printf("Custom sqrt (Newton-Raphson method) time: %lld ms\n", duration.count());
compare_square_root_quality();
```

실행 결과는 아래와 같다.\
꽤 쓸만한 속도와 정확도를 보여준다.\
물론, `sqrt()` 함수를 대체할 만한 수준은 아니다.

```text
Custom sqrt (Newton-Raphson method) time: 78 ms
RMSE: 0.0000000252, max_diff: 0.0000000064
```

## Quake III의 Fast Inverse Square Root

Quake III의 소스 코드에서는 아래와 같은 알고리즘을 적용한 제곱근이 사용되었었다.\
해당 코드에서는 반복 횟수를 2회로 두었지만, 여기선 **3회**로 살짝 늘렸다.

```cpp
start = chrono::high_resolution_clock::now();
for (size_t i = 0; i < test_count; ++i)
{
    float x = static_cast<float>(test_values[i]);
    if (x == 0.0f)
    {
        test_results[i] = 0.0;
        continue;
    }
    union {
        float f;
        uint32_t i;
    } conv;
    conv.f = x;
    conv.i = 0x5f3759df - (conv.i >> 1);
    float guess = conv.f;
    guess = guess * (1.5f - 0.5f * x * guess * guess); // 1st iteration
    guess = guess * (1.5f - 0.5f * x * guess * guess); // 2nd iteration
    guess = guess * (1.5f - 0.5f * x * guess * guess); // 3rd iteration
    test_results[i] = static_cast<double>(1.0f / guess);
}
stop = chrono::high_resolution_clock::now();
duration = chrono::duration_cast<chrono::milliseconds>(stop - start);
printf("Custom sqrt (Quake method) time: %lld ms\n", duration.count());
compare_square_root_quality();
```

위 코드에서 사용된 `0x5f3759df`는 근거 없는 경험치... 같은 건 아니다.\
float의 bias가 127인 점을 활용해서 $$\sqrt{2^{127}}$$과 유사한 값[^3]을 사용한 것이다.

결과는 아래와 같다.\
FPU가 강력하지 않은 환경이라면 충분히 적용할만한 수준의 정확도와 속도를 보여준다.

```text
Custom sqrt (Quake method) time: 24 ms
RMSE: 0.0000006315, max_diff: 0.0000039874
```

## double에서의 Fast Inverse Square Root

앞에서 사용된 Quake의 알고리즘은 double에서도 적용 가능하다.\
double의 bias는 1023이므로 $$\sqrt{2^{1023}}$$ 정도의 값을 적용하면 된다.\
이번에도 약 1.3% 더 큰 값이 통상적으로 사용된다.

```cpp
start = chrono::high_resolution_clock::now();
for (size_t i = 0; i < test_count; ++i)
{
    double x = test_values[i];
    if (x == 0.0)
    {
        test_results[i] = 0.0;
        continue;
    }
    union {
        double d;
        uint64_t i;
    } conv;
    conv.d = x;
    conv.i = 0x5fe6ec85e7de30da - (conv.i >> 1);
    double guess = conv.d;
    guess = guess * (1.5 - 0.5 * x * guess * guess); // 1st iteration
    guess = guess * (1.5 - 0.5 * x * guess * guess); // 2nd iteration
    guess = guess * (1.5 - 0.5 * x * guess * guess); // 3rd iteration
    test_results[i] = 1.0 / guess;
}
stop = chrono::high_resolution_clock::now();
duration = chrono::duration_cast<chrono::milliseconds>(stop - start);
printf("Custom sqrt (Quake - double version) time: %lld ms\n", duration.count());
compare_square_root_quality();
```

결과는 아래와 같다.\
그야말로 경이로운 결과를 보여준다.

```text
Custom sqrt (Quake - double version) time: 22 ms
RMSE: 0.0000000002, max_diff: 0.0000000000
```

## 결론

위 결과를 하나의 표로 나타내면 아래와 같다.

| 구분 | duration | RMSE | max_diff |
| ---- | ---- | ---- | ---- |
| sqrt | 22 ms | 0.0000000000 | 0.0000000000 |
| sqrtf | 4 ms | 0.0000003271 | 0.0000010700 |
| Newton-Raphson | 78 ms | 0.0000000252 | 0.0000000064 |
| Quake III | 24 ms | 0.0000006315 | 0.0000039874 |
| Fast SQRT in double | 22 ms | 0.0000000002 | 0.0000000000 |

1. 통상적인 환경이라면 그냥 `sqrt()` 사용하면 됨
2. 기원 전부터 내려온 이 방식은 그야말로 위대한 지성의 산물임
3. magic number를 활용한 방식은 대단히 강력함
   - 여기서는 반복 횟수를 3회로 제한했는데, 4회로만 올려도 정확도마저 `sqrt()`에 육박함

[^1]: 기원전 약 2000년~1600년경, 고대 바빌로니아 시대
[^2]: 1세기 경, 알렉산드리아의 헤론
[^3]: 정확히는 그 값보다 약 1.3% 큰 값임
