---
layout: single
title: "쿼터니언 곱을 SIMD를 활용하여 최적화 해보자"
date: 2025-08-12 20:42:00 +0900
categories:
  - algorithm
---

## 쿼터니언의 곱셈

다음와 같은 두 개의 쿼터니언이 있을 때

$$
q_1 = (a_1, b_1, c_1, d_1) \quad\text{(w, x, y, z 순서)}
$$

$$
q_2 = (a_2, b_2, c_2, d_2)
$$

이 두 쿼터니언의 **Hamilton 곱** $$q = q_1 \times q_2$$는 다음과 같이 정의된다.

$$
\begin{aligned}
a &= a_1 a_2 - b_1 b_2 - c_1 c_2 - d_1 d_2 \\
b &= a_1 b_2 + b_1 a_2 + c_1 d_2 - d_1 c_2 \\
c &= a_1 c_2 - b_1 d_2 + c_1 a_2 + d_1 b_2 \\
d &= a_1 d_2 + b_1 c_2 - c_1 b_2 + d_1 a_2
\end{aligned}
$$

## 쿼터니언 곱셈의 C++언어 구현

쿼터니언의 곱셈을 C++ 언어로 구현하면 대략 아래와 같은 형태가 된다.\
곱셈 연산자 오버로딩을 사용하면 상당히 유용하게 사용할 수 있다.

```cpp
template<typename T =double>
class Quaternion {
    template<typename T1>
    Quaternion operator*=(const Quaternion<T1>& y) {

        T at = _a * y.a() - _b * y.b() - _c * y.c() - _d * y.d();
        T bt = _a * y.b() + _b * y.a() + _c * y.d() - _d * y.c();
        T ct = _a * y.c() - _b * y.d() + _c * y.a() + _d * y.b();
        T dt = _a * y.d() + _b * y.c() - _c * y.b() + _d * y.a();

        _a = at;
        _b = bt;
        _c = ct;
        _d = dt;

        return *this;
    }
}

typedef Quaternion<double> Qd;
```

## AVX로 최적화 구현

AVX를 활용하면 좀 더 빠른 계산을 할 수 있을 것 같다.\
여러 개의 쿼터니언을 곱할 수 있도록 인자를 벡터로 받기로 했다.\
더불어, 계산이 끝난 뒤에 정규화하는 기능도 추가했다.

```cpp
Qd quat_mul_avx(const std::vector<Qd>& q)
{
    const size_t count = q.size();
    __m256d r;
    if (count == 0)
        return Qd{ 1.0, 0.0, 0.0, 0.0 }; // identity quaternion
    else {
        r = _mm256_set_pd(q[0].d(), q[0].c(), q[0].b(), q[0].a());
        const __m256d sign_t1 = _mm256_castsi256_pd(_mm256_set_epi64x(
            0x0000000000000000ULL, // z: +
            0x8000000000000000ULL, // y: -
            0x0000000000000000ULL, // x: +
            0x8000000000000000ULL  // w: -
        ));
        const __m256d sign_t2 = _mm256_castsi256_pd(_mm256_set_epi64x(
            0x8000000000000000ULL, // z: -
            0x0000000000000000ULL, // y: +
            0x0000000000000000ULL, // x: +
            0x8000000000000000ULL  // w: -
        ));
        const __m256d sign_t3 = _mm256_castsi256_pd(_mm256_set_epi64x(
            0x0000000000000000ULL, // z: +
            0x0000000000000000ULL, // y: +
            0x8000000000000000ULL, // x: -
            0x8000000000000000ULL  // w: -
        ));
        for (size_t i = 1; i < count; ++i) {
            __m256d b = _mm256_set_pd(q[i].d(), q[i].c(), q[i].b(), q[i].a());

            __m256d aw = _mm256_permute4x64_pd(r, _MM_SHUFFLE(0, 0, 0, 0));
            __m256d ax = _mm256_permute4x64_pd(r, _MM_SHUFFLE(1, 1, 1, 1));
            __m256d ay = _mm256_permute4x64_pd(r, _MM_SHUFFLE(2, 2, 2, 2));
            __m256d az = _mm256_permute4x64_pd(r, _MM_SHUFFLE(3, 3, 3, 3));

            __m256d b_xwzy = _mm256_permute4x64_pd(b, _MM_SHUFFLE(2, 3, 0, 1));
            __m256d b_yzwx = _mm256_permute4x64_pd(b, _MM_SHUFFLE(1, 0, 3, 2));
            __m256d b_zyxw = _mm256_permute4x64_pd(b, _MM_SHUFFLE(0, 1, 2, 3));

            __m256d term0 = _mm256_mul_pd(aw, b);
            __m256d term1 = _mm256_mul_pd(ax, b_xwzy); term1 = _mm256_xor_pd(term1, sign_t1);
            __m256d term2 = _mm256_mul_pd(ay, b_yzwx); term2 = _mm256_xor_pd(term2, sign_t2);
            __m256d term3 = _mm256_mul_pd(az, b_zyxw); term3 = _mm256_xor_pd(term3, sign_t3);

            r = term0;
            r = _mm256_add_pd(r, term1);
            r = _mm256_add_pd(r, term2);
            r = _mm256_add_pd(r, term3);
        }
    }
    // -------- normalize(r): sqrt + div --------
    __m256d sq = _mm256_mul_pd(r, r);
    __m256d sum1 = _mm256_add_pd(sq, _mm256_permute4x64_pd(sq, _MM_SHUFFLE(2, 3, 0, 1)));
    __m256d sum2 = _mm256_add_pd(sum1, _mm256_permute4x64_pd(sum1, _MM_SHUFFLE(1, 0, 3, 2)));
    __m256d len2 = _mm256_permute4x64_pd(sum2, _MM_SHUFFLE(0, 0, 0, 0));
    __m256d len = _mm256_sqrt_pd(len2);

    const __m256d eps = _mm256_set1_pd(1e-300);         // double용 매우 작은 임계값
    __m256d mask = _mm256_cmp_pd(len, eps, _CMP_LT_OQ); // len < eps

    __m256d inv = _mm256_div_pd(_mm256_set1_pd(1.0), len);
    __m256d nor = _mm256_mul_pd(r, inv);
    const __m256d ident = _mm256_set_pd(0.0, 0.0, 0.0, 1.0);
    nor = _mm256_or_pd(_mm256_and_pd(mask, ident), _mm256_andnot_pd(mask, nor));

    double ret[4];
    _mm256_storeu_pd(ret, nor);
    return Qd{ ret[0], ret[1], ret[2], ret[3] };
}
```

## AVX와 FMA3를 활용한 최적화 구현

이왕 하는 거 FMA3를 활용해서 구현하는 것으로 더 밀여붙여보기로 했다.

```cpp
static __forceinline __m256d _invsqrt_nr_avx_fma(__m256d x) {
    __m128 xf32 = _mm256_cvtpd_ps(x);
    __m128 y0f = _mm_rsqrt_ps(xf32);
    __m256d y = _mm256_cvtps_pd(y0f);

    const __m256d c05 = _mm256_set1_pd(0.5), c15 = _mm256_set1_pd(1.5);

    // y = y * (1.5 - 0.5*x*y*y)  (두 번)
    __m256d y2 = _mm256_mul_pd(y, y);
    __m256d t = _mm256_fnmadd_pd(c05, _mm256_mul_pd(x, y2), c15);
    y = _mm256_mul_pd(y, t);

    y2 = _mm256_mul_pd(y, y);
    t = _mm256_fnmadd_pd(c05, _mm256_mul_pd(x, y2), c15);
    y = _mm256_mul_pd(y, t);
    return y;
}

Qd quat_mul_avx_fma(const std::vector<Qd>& q)
{
    const size_t count = q.size();
    __m256d r;
    if (count == 0)
        return Qd{ 1.0, 0.0, 0.0, 0.0 }; // identity quaternion
    else {
        r = _mm256_set_pd(q[0].d(), q[0].c(), q[0].b(), q[0].a());

        const __m256d s1 = _mm256_castsi256_pd(_mm256_set_epi64x(
            0x0000000000000000ULL, // z: +
            0x8000000000000000ULL, // y: -
            0x0000000000000000ULL, // x: +
            0x8000000000000000ULL  // w: -
        ));
        const __m256d s2 = _mm256_castsi256_pd(_mm256_set_epi64x(
            0x8000000000000000ULL, // z: -
            0x0000000000000000ULL, // y: +
            0x0000000000000000ULL, // x: +
            0x8000000000000000ULL  // w: -
        ));
        const __m256d s3 = _mm256_castsi256_pd(_mm256_set_epi64x(
            0x0000000000000000ULL, // z: +
            0x0000000000000000ULL, // y: +
            0x8000000000000000ULL, // x: -
            0x8000000000000000ULL  // w: -
        ));

        for (size_t i=1; i < count; ++i) {
            __m256d b = _mm256_set_pd(q[i].d(), q[i].c(), q[i].b(), q[i].a());

            __m256d aw = _mm256_permute4x64_pd(r, _MM_SHUFFLE(0, 0, 0, 0));
            __m256d ax = _mm256_permute4x64_pd(r, _MM_SHUFFLE(1, 1, 1, 1));
            __m256d ay = _mm256_permute4x64_pd(r, _MM_SHUFFLE(2, 2, 2, 2));
            __m256d az = _mm256_permute4x64_pd(r, _MM_SHUFFLE(3, 3, 3, 3));

            __m256d bxwzy = _mm256_permute4x64_pd(b, _MM_SHUFFLE(2, 3, 0, 1));
            __m256d byzwx = _mm256_permute4x64_pd(b, _MM_SHUFFLE(1, 0, 3, 2));
            __m256d bzyxw = _mm256_permute4x64_pd(b, _MM_SHUFFLE(0, 1, 2, 3));

            r = _mm256_mul_pd(az, _mm256_xor_pd(bzyxw, s3));
            r = _mm256_fmadd_pd(ay, _mm256_xor_pd(byzwx, s2), r);
            r = _mm256_fmadd_pd(ax, _mm256_xor_pd(bxwzy, s1), r);
            r = _mm256_fmadd_pd(aw, b, r);
        }
    }

    // normalize
    __m256d sq = _mm256_mul_pd(r, r);
    __m256d t1 = _mm256_add_pd(sq, _mm256_permute4x64_pd(sq, _MM_SHUFFLE(2, 3, 0, 1)));
    __m256d sum = _mm256_add_pd(t1, _mm256_permute4x64_pd(t1, _MM_SHUFFLE(1, 0, 3, 2)));
    __m256d len2 = _mm256_permute4x64_pd(sum, _MM_SHUFFLE(0, 0, 0, 0));

    const __m256d tiny = _mm256_set1_pd(1e-300);
    __m256d small = _mm256_cmp_pd(len2, tiny, _CMP_LT_OQ);

    __m256d inv = _invsqrt_nr_avx_fma(len2);
    __m256d nor = _mm256_mul_pd(r, inv);
    const __m256d ident = _mm256_set_pd(0.0, 0.0, 0.0, 1.0);
    nor = _mm256_or_pd(_mm256_and_pd(small, ident), _mm256_andnot_pd(small, nor));

    double ret[4];
    _mm256_storeu_pd(ret, nor);
    return Qd{ ret[0], ret[1], ret[2], ret[3] };
}
```

## 실행 성능 비교

위의 함수들로 실행한 결과는 거의 동일하다.\
**거의** 라는 표현을 쓴 이유는 비트 단위까지는 동일하지 않은 결과가 가끔 나오기 때문.

다양한 입력에 대해 확인 해본 결과 세 코드들은 모두 서로 교환 가능한 수준까지 동일한 결과를 보여준다.\
그렇다면 다음으로 확인할 것은 실행 성능이다.

동일합 입력값들에 대해서 천만번 씩 실행한 결과는 아래와 같다.\
실행 환경은 Ryzen 9700X + Windows 11.

```text
Speed test:
Time taken for 10,000,000 multiplications: 39 ms
qd      [a b c d] = [-0.2930861888 0.0078265947 0.8182374980 0.4944963368]
Time taken for 10,000,000 multiplications: 138 ms
qd(AVX) [a b c d] = [-0.2930861888 0.0078265947 0.8182374980 0.4944963368]
Time taken for 10,000,000 multiplications: 149 ms
qd(FMA) [a b c d] = [-0.2930861888 0.0078265947 0.8182374980 0.4944963368]
```

그런데, 결과가 뭔가 묘하다.\
그냥 곱셈한 것보다 AVX/FMA를 활용한 쪽이 더 느리다...

이것이 실제 연산 성능에 의한 것인지, 함수 호출 메커니즘에 의한 것인지 확인이 필요하다.\
그래서 곱셈 연산자 오버로딩 버전도 동일한 함수 형태로 만들어본다.

```cpp
Qd quat_mul(const std::vector<Qd>& q)
{
    const size_t count = q.size();
    if (count == 0)
        return Qd{ 1.0, 0.0, 0.0, 0.0 }; // identity quaternion
    else if (count == 1) {
        Qd result = q[0];
        normalize(result);
        return result;
    }
    else {
        Qd result = q[0];
        for (size_t i = 1; i < count; ++i)
            result = result * q[i];
        normalize(result);
        return result;
    }
}
```

이 함수까지 실행하여 비교한 결과는 아래와 같다.

```text
Speed test:
Time taken for 10,000,000 multiplications: 36 ms
qd0     [a b c d] = [-0.2930861888 0.0078265947 0.8182374980 0.4944963368]
Time taken for 10,000,000 multiplications: 177 ms
qd(*)   [a b c d] = [-0.2930861888 0.0078265947 0.8182374980 0.4944963368]
Time taken for 10,000,000 multiplications: 134 ms
qd(AVX) [a b c d] = [-0.2930861888 0.0078265947 0.8182374980 0.4944963368]
Time taken for 10,000,000 multiplications: 150 ms
qd(FMA) [a b c d] = [-0.2930861888 0.0078265947 0.8182374980 0.4944963368]
```

두 번째 내용\[**qd(\*)**\]이 마지막에 추가한 함수 호출 형식으로 다시 구현한 결과이다.\
AVX 등을 활용한 결과가 좀 더 빠른 결과를 확인할 수 있다.

## 결론

1. 연산 성능 자체는 **AVX**만 활용한 쪽이 제일 빠름
2. FMA3를 활용한 것은 오히려 성능이 미묘하게 떨어짐
3. 함수 호출 구조를 고려하면 **곱셈 연산자를 오버로딩** 하는 형태가 최선임

제길... 뭐하러 이런 짓을 한 거지...
