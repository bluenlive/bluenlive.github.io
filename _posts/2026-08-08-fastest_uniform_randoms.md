---
layout: single
title: "굉장히 빠르게 균일(uniform) 난수 생성하기"
date: 2026-8-8 10:22:00 +0900
categories:
  - algorithm
tags: ["Ryzen", "SplitMix64", "Xoshiro", "MT19937", "SFMT19937", "ChaCha20"]
toc: true
toc_label: "Contents"
#toc_icon: "cog"
toc_icon: "book-open"
toc_sticky: true
---

## 들어가기에 앞서

[예전 글](/algorithm/fastest_normal_randoms/)에서 정규분포 난수를 빠르게 생성하는 방법을 기술했었다.\
그런데, 정규분포 난수는 바로 생성하는 것이 아니라 **균일(uniform) 난수**를 생성한 뒤 변환 해야 한다.

균일 난수 생성을 위해 C언어 초창기에는 `rand()` 함수를 사용했었다.\
하지만, 이 함수는 느리고 순환 주기도 너무 작아 이제는 쓰지 않는 게 좋다.\
C++에서는 C++11부터 도입된 `MT19937`이 표준으로 자리잡았고, **훌륭한 품질**을 보여주고 있다.

그런데, 이제 **대 SIMD**의 시대인데, MT19937은 SIMD 병렬화를 고려하지 않고 개발됐다[^1].\
이후 SIMD를 활용한 더 빠른 난수 생성 알고리즘들이 등장했다.

이렇게 등장한 알고리즘 중에는 **암호학에서 사용할 수 있는** 품질을 제공하는 것도 있다.

---

## 알고리즘 심화꞉ SplitMix64, Xoshiro256, SFMT19937, ChaCha20

고성능 난수 생성 시스템을 구축할 때 난수 엔진 초기화와 생성을 구분해서 봐야 한다.\
균일 난수를 다루는 알고리즘들에서 이를 분리해서 코드와 함께 정리한다.

---

### 0. SplitMix64꞉ 상태 공간을 고르게 채우는 시드 초기화 엔진

Xoshiro와 같은 현대적 난수 생성기는 내부 상태(State)로 256비트 이상의 큰 공간을 사용한다.\
단일 정수 시드(예꞉ `std::random_device`)로 256비트를 직접 채우면 초기 비트에 편향이 생길 수 있다.

`SplitMix64`는 64비트 시드 하나를 받아 내부 비트를 고르게 확산시켜 상태 벡터를 안전하게 초기화한다.\
**2014년**에 **가이 스틸 주니어**, **더그 리**, **크리스틴 플러드** 연구진이 개발했다.

{: .bluebox-blue}
* **황금비 상수 (`0x9E3779B97F4A7C15ULL`)**꞉\
$$2^{64}$$를 황금비$$\left(\frac{1+\sqrt{5}}{2}\right)$$로 나눈 값\
시드가 `0`이라도 덧셈 수열을 통해 비트를 고르게 분산시키며 $$2^{64}$$의 최대 주기를 보장함
* **비트 혼합 상수 (`0xBF58476D1CE4E5B9ULL`, `0x94D049BB133111EBULL`)**꞉\
입력 비트 1개만 바뀌어도 출력 비트의 약 50%가 뒤흔들리는 비트 파급 효과를 만들어냄

```cpp
#include <cstdint>

// 64비트 단일 시드를 고르게 비트 확산시켜 난수 생성기 초기 상태로 제공
// state도 이 과정에서 계속 변함
uint64_t SplitMix64(uint64_t& state)
{
    uint64_t z = (state += 0x9E3779B97F4A7C15ULL);
    z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ULL;
    z = (z ^ (z >> 27)) * 0x94D049BB133111EBULL;
    return z ^ (z >> 31);
}
```

---

### 1. Xoshiro256꞉ 초고속 비암호학적 의사난수 엔진

Xoshiro256은 XOR, Shift, Rotate 연산만으로 동작하는 초고속 PRNG[^2]다.\
**2018년**에 **데이비드 블랙맨**과 **세바스티아노 비냐** 교수가 개발했다.\
이름은 알고리즘의 핵심인 `XOR` `Shift` `Rotate`의 약어이다.

256비트 상태 공간을 가지며 주기는 $$2^{256}-1$$에 달한다.\
간단히(응?) 계산해보면 아래와 같은 **거대한 주기**를 갖는다는 뜻.

$$2^{256}-1 = 2^{6} \times \left( {2}^{10} \right) ^{25} - 1 \approx 64 \times 10 ^ {75}$$

{: .bluebox-blue}
* **동작 구조**꞉\
64비트 상태 변수 4개($$s_0 \sim s_3$$)를 비트 연산으로 빠르게 교차 갱신
* **StarStar(`**`) 스크램블러**꞉\
`Rotl(s[1] * 5, 7) * 9` 연산을 적용\
선형 구조 패턴을 깨뜨려 BigCrush 같은 엄격한 난수성 검증을 통과하도록 만들어준다고 함
* **주요 용도**꞉\
게임, 그래픽스, 시뮬레이션 등 대량의 무작위 수치가 필요한 환경

```cpp
#include <cstdint>

struct Xoshiro256StarStar
{
    uint64_t s[4]; // SplitMix64로 초기화된 256비트 상태 공간

    void Init(uint64_t seed)
    {
        s[0] = SplitMix64(seed);
        s[1] = SplitMix64(seed);
        s[2] = SplitMix64(seed);
        s[3] = SplitMix64(seed);
    }

    static inline uint64_t Rotl(uint64_t x, int k)
    {
        return (x << k) | (x >> (64 - k));
    }

    uint64_t Next()
    {
        // StarStar 스크램블러 결과 반환
        // Plus, PlusPlus 등의 변종도 있음
        uint64_t result = Rotl(s[1] * 5, 7) * 9;

        // XOR / Shift / Rotate 기반 상태 갱신
        uint64_t t = s[1] << 17;
        s[2] ^= s[0];
        s[3] ^= s[1];
        s[1] ^= s[2];
        s[0] ^= s[3];

        s[2] ^= t;
        s[3] = Rotl(s[3], 45);

        return result;
    }
};
```

---

### 2. SFMT19937꞉ SIMD 파이프라인에 최적화된 메르센 트위스터

SFMT19937은 고전적 메르센 트위스터(MT19937)를 현대 CPU의 SIMD 구조에 맞게 재설계한 난수 엔진이다.\
MT19937(1997년)과 SFMT19937(**2006년**) 모두 일본의 **마쓰모토 마코토** 교수 연구진이 주도하여 개발했다.

{: .bluebox-blue}
* **MT19937과의 차이점**꞉
  * **연산 단위**꞉\
기존 MT19937은 32비트 스칼라 연산 중심이었지만, SFMT19937은 128비트 벡터 블록 단위로 연산
  * **생성 속도**꞉\
128비트 레지스터 활용으로 기존 MT19937 대비 2~4배 빠름
  * **회복력 개선**꞉\
초기 상태에 `0` 비트가 많이 포함되어 있을 때 정상 난수 분포로 회복되는 속도가 MT19937보다 빠름
  * **거대 주기 유지**꞉\
$$2^{19937}-1$$이라는 거대한 주기와 균일 분포 특성을 그대로 유지함
* **주요 용도**꞉ 대규모 물리 시뮬레이션, 통계적 Monte Carlo 검증, 게임 서버 엔진

역시 간단히 계산해보면 아래와 같은 **초거대한 주기**를 갖는다.

$$2^{19937}-1 = 2^{7} \times \left( {2}^{10} \right) ^{1993} - 1 \approx 128 \times 10 ^ {5979}$$

```cpp
#include <cstdint>
#include <immintrin.h> // AVX2 SIMD 헤더

class SFMT19937Avx2Rng
{
private:
    static constexpr int N = 156;        // 128비트 블록 개수
    static constexpr int N256 = N / 2;   // 256비트 블록 개수 (78개)

    alignas(32) __m256i m_state[N256];   // 32바이트 정렬된 256비트 상태 공간
    int m_index = N * 4;                 // 32비트 읽기 인덱스 (624개)

    // 256비트 레지스터 내부에서 2개의 128비트 블록을 동시에 재귀 연산
    static inline __m256i Recursion256(__m256i a, __m256i b, __m256i c, __m256i d)
    {
        __m256i y = _mm256_srli_epi32(b, 11);
        __m256i z = _mm256_srli_si256(c, 1);
        __m256i v = _mm256_slli_epi32(d, 1);
        __m256i x = _mm256_slli_si256(a, 1);

        return _mm256_xor_si256(_mm256_xor_si256(a, x), 
                               _mm256_xor_si256(_mm256_xor_si256(y, z), v));
    }

    // 78개의 256비트 상태 블록(156개의 128비트 블록)을 일괄 갱신
    void GenerateBlocks()
    {
        // 128비트 단위의 의존성 오프셋을 256비트 오프셋으로 변환하여 처리
        for (int i = 0; i < N256 - 1; ++i) {
            m_state[i] = Recursion256(m_state[i], 
                                      m_state[(i + 1) % N256], 
                                      m_state[(i + 61) % N256], 
                                      m_state[(i + 1) % N256]);
        }

        m_index = 0;
    }

public:
    uint32_t Next()
    {
        if (m_index >= N * 4) {
            GenerateBlocks();
        }
        const uint32_t* ptr = reinterpret_cast<const uint32_t*>(m_state);
        return ptr[m_index++];
    }
};
```

이해를 돕기 위해 위의 AVX2 코드를 **비 SIMD 코드**로 기술하면 아래와 같다.

```cpp
#include <cstdint>

class SFMT19937ScalarRng
{
private:
    // 128비트 벡터를 표현하는 32비트 정수 4개 구조체
    struct W128
    {
        uint32_t u[4];
    };

    static constexpr int N = 156; // 128비트 블록 156개 (19,968비트)
    W128 m_state[N];              // 상태 공간
    int m_index = N * 4;          // 32비트 읽기 인덱스

    // SIMD 내장 함수 없이 32비트 연산만으로 128비트 블록 재귀 수행
    static inline W128 Recursion(W128 a, W128 b, W128 c, W128 d)
    {
        W128 r;

        // 1. 32비트 요소별 우측 시프트 (>> 11)
        uint32_t y0 = b.u[0] >> 11, y1 = b.u[1] >> 11, y2 = b.u[2] >> 11, y3 = b.u[3] >> 11;

        // 2. 128비트 전체 바이트 단위 우측 시프트 (1바이트 = 8비트)
        uint32_t z0 = (c.u[0] >> 8) | (c.u[1] << 24);
        uint32_t z1 = (c.u[1] >> 8) | (c.u[2] << 24);
        uint32_t z2 = (c.u[2] >> 8) | (c.u[3] << 24);
        uint32_t z3 = (c.u[3] >> 8);

        // 3. 32비트 요소별 좌측 시프트 (<< 1)
        uint32_t v0 = d.u[0] << 1, v1 = d.u[1] << 1, v2 = d.u[2] << 1, v3 = d.u[3] << 1;

        // 4. 128비트 전체 바이트 단위 좌측 시프트 (1바이트 = 8비트)
        uint32_t x0 = (a.u[0] << 8);
        uint32_t x1 = (a.u[1] << 8) | (a.u[0] >> 24);
        uint32_t x2 = (a.u[2] << 8) | (a.u[1] >> 24);
        uint32_t x3 = (a.u[3] << 8) | (a.u[2] >> 24);

        // 5. 비트 XOR 결합
        r.u[0] = a.u[0] ^ x0 ^ y0 ^ z0 ^ v0;
        r.u[1] = a.u[1] ^ x1 ^ y1 ^ z1 ^ v1;
        r.u[2] = a.u[2] ^ x2 ^ y2 ^ z2 ^ v2;
        r.u[3] = a.u[3] ^ x3 ^ y3 ^ z3 ^ v3;

        return r;
    }

    // 156개 블록 상태 갱신
    void GenerateBlocks()
    {
        int i;
        for (i = 0; i < N - 2; ++i) {
            m_state[i] = Recursion(m_state[i], m_state[i + 2], m_state[i + 122], m_state[i + 1]);
        }
        m_state[N - 2] = Recursion(m_state[N - 2], m_state[0], m_state[122], m_state[N - 1]);
        m_state[N - 1] = Recursion(m_state[N - 1], m_state[1], m_state[123], m_state[0]);

        m_index = 0;
    }

public:
    // 32비트 난수 반환
    uint32_t Next()
    {
        if (m_index >= N * 4) {
            GenerateBlocks();
        }
        const uint32_t* ptr = reinterpret_cast<const uint32_t*>(m_state);
        return ptr[m_index++];
    }
};
```

### 3. ChaCha20꞉ 암호학적 수준의 고품질 스트림 난수 엔진

ChaCha20은 다니엘 제이 번스타인(Daniel J. Bernstein)이 2008년에 설계한 스트림 암호 기반 알고리즘이다.\
**난수 간 상관관계를 원천 차단**해야 하는 고품질 시뮬레이션이나 보안 환경에서 쓰인다.

{: .bluebox-blue}
* **512비트 초기 행렬 구성**꞉\
128비트 고정 상수 + 256비트 Key(주 시드) + 32비트 카운터 + 96비트 Nonce로 구성
  * **고정 상수**꞉\
`"expand 32-byte k"`의 ASCII 값으로, 임의 백도어가 없음을 증명하는 표준 표식임\
상수를 다른 값으로 수정해도 난수 생성 자체는 문제 없지만, 그럼 ChaCha20이라 부를 수 없음
  * **Key (8개 uint32)**꞉\
난수 생성기의 메인 시드 역할
  * **Nonce (3개 uint32)**꞉\
동일한 Key 사용 시 서브 난수 스트림을 구분짓는 보조 시드 역할
* **20 라운드 혼합 (10 이중 라운드)**꞉\
1회 루프에서 열(Column) 4회, 대각선(Diagonal) 4회의 QuarterRound를 수행\
즉, 10번 루프 동안 총 20 라운드가 연산됨
* **초기 상태 합산**꞉\
20 라운드를 거친 결괏값에 초기 행렬을 더해 역연산(예측)을 불가능하게 만듦

```cpp
#include <cstdint>

class ChaCha20Rng
{
private:
    uint32_t m_key[8];      // 256비트 주 시드
    uint32_t m_nonce[3];    // 96비트 보조 시드 (스트림 구분)
    uint32_t m_counter = 0; // 블록 순번 카운터

    uint32_t m_buffer[16];  // 512비트 (64바이트) 난수 블록 버퍼
    int m_index = 16;       // 버퍼 읽기 인덱스

    static inline void QuarterRound(uint32_t& a, uint32_t& b, uint32_t& c, uint32_t& d)
    {
        a += b; d ^= a; d = (d << 16) | (d >> 16);
        c += d; b ^= c; b = (b << 12) | (b >> 20);
        a += b; d ^= a; d = (d << 8)  | (d >> 24);
        c += d; b ^= c; b = (b << 7)  | (b >> 25);
    }

    // 512비트 난수 한 블록(64바이트)을 생성하는 내부 함수
    void GenerateBlock()
    {
        // 1. 초기 512비트 상태 행렬 구성
        uint32_t input[16] = {
            0x61707865, 0x3320646e, 0x79622d32, 0x6b206574, // "expand 32-byte k"
            m_key[0], m_key[1], m_key[2], m_key[3],
            m_key[4], m_key[5], m_key[6], m_key[7],
            m_counter++,                                    // 블록 생성 시 카운터 증가
            m_nonce[0], m_nonce[1], m_nonce[2]
        };

        uint32_t x[16];
        for (int i = 0; i < 16; ++i) x[i] = input[i];

        // 2. 20 라운드 (10 이중 라운드) 혼합 연산
        for (int i = 0; i < 10; ++i) {
            // 열(Column) 라운드
            QuarterRound(x[0], x[4], x[8],  x[12]);
            QuarterRound(x[1], x[5], x[9],  x[13]);
            QuarterRound(x[2], x[6], x[10], x[14]);
            QuarterRound(x[3], x[7], x[11], x[15]);

            // 대각선(Diagonal) 라운드
            QuarterRound(x[0], x[5], x[10], x[15]);
            QuarterRound(x[1], x[6], x[11], x[12]);
            QuarterRound(x[2], x[7], x[8],  x[13]);
            QuarterRound(x[3], x[4], x[9],  x[14]);
        }

        // 3. 초기 상태 합산 후 버퍼 저장 (512비트 난수 산출)
        for (int i = 0; i < 16; ++i) {
            m_buffer[i] = x[i] + input[i];
        }
        m_index = 0;
    }

public:
    ChaCha20Rng(const uint32_t key[8], const uint32_t nonce[3])
    {
        for (int i = 0; i < 8; ++i) m_key[i] = key[i];
        for (int i = 0; i < 3; ++i) m_nonce[i] = nonce[i];
    }

    // 32비트 난수를 연속으로 반환하는 스트림 인터페이스
    uint32_t Next()
    {
        if (m_index >= 16) {
            GenerateBlock(); // 버퍼 소진 시 다음 64바이트 생성
        }
        return m_buffer[m_index++];
    }
};
```

---

## 성능 및 기능 비교

### 생성 성능 비교

주요 알고리즘의 성능을 비교한 결과는 아래와 같다.\
모두 동일하게 **750만 개**의 난수를 생성하였으며, 사용된 CPU는 **Ryzen 7 9700X**.

![image](/images/2026-08-08/uniform_B_okl_s36_Q.webp)
*단위는 M/s, 초당 몇백만개를 생성하는가임*

그래프에서 보여주는 내용은 `rand()` 및 `MT19937`을 함께 비교한 결과이다.\
난수로서의 품질은 대동소이하며, 모두 평균은 0, 표준편차는 $$\frac{1}{\sqrt{12}} \approx 0.228675$$에 근접했다.\
특이할 점은 `Xoshiro256`과 `SFMT19937`의 생성 속도가 C++ 표준인 `MT19937`의 3배에 달한다는 점.\
그리고, 암호학적 난수인 `ChaCha20`도 제대로 구현하면 `MT19937`보다 조금이나마 빠르게 동작한다.

### 기능 비교

| 구분 | SplitMix64 | Xoshiro256 | SFMT19937 | ChaCha20 |
| --- | --- | --- | --- | --- |
| **주 역할** | 시드 확산 및 초기화 | 고속 균일 난수 생성 | 대용량/고차원 시뮬레이션 | 암호학적/고품질 난수 |
| **상태 크기** | 64-bit | 256-bit | 19,968-bit | 512-bit |
| **주기** | $$2^{64}$$ | $$2^{256}-1$$ | $$2^{19937}-1$$ | $$2^{68}$$ (블록) |
| **연산 특성** | 시프트, 곱셈 | 비트 연산 (XOR/Shift/Rotate) | 128-bit SIMD 레지스터 연산 | ARX[^3] 및 20 라운드 블록 암호 |
| **적합한 상황** | PRNG 상태 초기화 시 | 일반 대량 난수 필요 시 | 대규모 물리/통계 시뮬레이션 | 보안 및 정밀 분석 필요 시 |

[^1]: MT19937이 만들어진 1997년은 인텔 MMX가 처음 나온 시기였으니 고려하기 힘들었음
[^2]: PRNG꞉ 의사 난수 생성기, Pseudo-Random Number Generator
[^3]: ARX꞉ Addition(덧셈), Rotation(비트 회전), XOR(배타적 논리합)
