---
layout: single
title: "C언어로 float16 빠르게 읽기"
#date: 2025-3-10 22:49:00 +0900
categories:
  - algorithm
---

[이전 글](/algorithm/tiffloader/)을 쓰고 나서 생각해보니 굳이 Half-precision floating-point(float16)을 일일이 읽을 필요가 없었다.\
IEEE 754 포맷에 맞춰 적절하게 변환하면 된다.

float16의 구조에 대해 얘기할 겸해서 간단하게 변환하는 법을 적어본다.

## 정공법

[이전 글](/algorithm/tiffloader/)에서 적은 코드다.\
아래와 같이 하면 정확하게 float16을 읽을 수 있다.

```cpp
static float memreadieee754f16(unsigned char* mem, int bigendian)
{
    unsigned long buff = 0;
    unsigned long buff2 = 0;
    unsigned long mask;
    int sign;
    int exponent;
    int shift;
    int i;
    int significandbits = 10;
    int expbits = 5;
    double fnorm = 0.0;
    double bitval;
    double answer;

    if (bigendian)
        buff = (mem[0] << 8) | mem[1];
    else
        buff = (mem[1] << 8) | mem[0];

    sign = (buff & 0x8000) ? -1 : 1;
    mask = 0x200;
    exponent = (buff & 0x7C00) >> 10;
    bitval = 0.5;
    for (i = 0; i < significandbits; i++)
    {
        if (buff & mask)
            fnorm += bitval;
        bitval /= 2;
        mask >>= 1;
    }
    if (exponent == 0 && fnorm == 0.0)
        return 0.0f;
    shift = exponent - ((1 << (expbits - 1)) - 1); /* exponent = shift + bias */

    if (shift == 16 && fnorm != 0.0)
    {
        const static unsigned long pNaN = 0x7FC00000;
        return *(float*)&pNaN;
    }
    if (shift == 16 && fnorm == 0.0)
    {
        const static unsigned long pInf = 0x7F800000;
        const static unsigned long nInf = 0xFF800000;
        return sign == 1 ? *(float*)&pInf : *(float*)&nInf;
    }
    if (shift > -15)
    {
        answer = ldexp(fnorm + 1.0, shift);
        return (float)answer * sign;
    }
    else
    {
        if (fnorm == 0.0)
            return 0.0f;
        shift = -14;
        while (fnorm < 1.0)
        {
            fnorm *= 2;
            shift--;
        }
        answer = ldexp(fnorm, shift);
        return (float)answer * sign;
    }
}
```

## IEEE 754 포맷에 맞게 변환

IEEE 754는 당연하게도 서로 비슷한 구조로 되어있다.\
MSB가 부호, 그 다음이 exponent(지수), 마지막으로 fraction(가수)이다.

![image](/images/2025-03-10/float16.png){: .align-center}
*float16*

![image](/images/2025-03-10/float32.png){: .align-center}
*float*

여기서, 지수는 offset과 함께 정의되어 있다는 점만 고려하면 간단히 변환이 가능하다.\
float16은 offset이 15($$ 2^4 - 1 $$)이고, float는 offset이 127($$ 2^7 - 1 $$)이다.\
fraction은 간단하게 shift만 하면 된다.

```cpp
static float memreadieee754f16_fast(unsigned char* mem, int bigendian)
{
    unsigned long u32;
    if (bigendian)
        u32 = (mem[0] << 8) | mem[1];
    else
        u32 = (mem[1] << 8) | mem[0];

    const unsigned long u32_sign = (u32 & 0x8000) << 16;
    unsigned long u32_expo = u32 & 0x7c00;
    if (u32_expo == 0x7c00)
        u32_expo = 0xff << 23;
    else if (u32_expo)
        u32_expo = ((u32_expo >> 10) + (127 - 15)) << 23;
    const unsigned long u32_frac = (u32 & 0x03ff) << (23 - 10);
    u32 = u32_sign | u32_expo | u32_frac;

    return *(float*)&u32;
}

```

## IEEE 754 포맷에 맞게 더 빠르게 변환

위와 사실상 동일한 코드다.\
단, exponent를 처리할 때 좀 더 최적화한 동작을 위해 **테이블**로 구현했다.

```cpp
static float memreadieee754f16_fast2(unsigned char* mem, int bigendian)
{
    unsigned long u32;
    if (bigendian)
        u32 = (mem[0] << 8) | mem[1];
    else
        u32 = (mem[1] << 8) | mem[0];

    const static unsigned long u32_expo_table[] = {
        0x00000000, 0x38800000, 0x39000000, 0x39800000,
        0x3a000000, 0x3a800000, 0x3b000000, 0x3b800000,
        0x3c000000, 0x3c800000, 0x3d000000, 0x3d800000,
        0x3e000000, 0x3e800000, 0x3f000000, 0x3f800000,
        0x40000000, 0x40800000, 0x41000000, 0x41800000,
        0x42000000, 0x42800000, 0x43000000, 0x43800000,
        0x44000000, 0x44800000, 0x45000000, 0x45800000,
        0x46000000, 0x46800000, 0x47000000, 0x7f800000,
    };

    const unsigned long u32_sign = (u32 & 0x8000) << 16;
    const unsigned long u32_expo = u32_expo_table[(u32 & 0x7c00) >> 10];
    const unsigned long u32_frac = (u32 & 0x03ff) << (23 - 10);
    u32 = u32_sign | u32_expo | u32_frac;

    return *(float*)&u32;
}
```

## float → double 변환

똑같은 원리로 float를 double로도 변환할 수 있다.\
물론, 이 작업은 큰 의미는 없다. 그냥 재미로(?) 만들어본 것.

```cpp
static double f32tof64(const float f)
{
    const unsigned long u32 = *(const unsigned long*)&f;
    unsigned long long u64 = (unsigned long long)u32;

    const unsigned long long u64_sign = (u64 & 0x80000000) << 32;
    unsigned long long u64_expo = u64 & 0x7f800000;
    if (u64_expo == 0x7f800000)
        u64_expo = 0x7ff << 52;
    else if (u64_expo)
        u64_expo = ((u64_expo >> 23) + (1023 - 127)) << 52;
    const unsigned long long u64_frac = (u64 & 0x7fffff) << (52 - 23);
    u64 = u64_sign | u64_expo | u64_frac;

    return *(double*)&u64;
}
```
