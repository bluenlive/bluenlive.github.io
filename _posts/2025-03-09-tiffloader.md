---
layout: single
title: "TIFF 읽기 전용 라이브러리 tiffloader"
#date: 2025-3-9 21:15:00 +0900
categories:
  - algorithm
---

## TIFF loader 소개

TIFF 포맷을 다루기 위해선 역시 [LibTIFF](https://gitlab.com/libtiff/libtiff/){:target="_blank"}를 사용하는 것이 가장 보편적이다.\
그런데, 읽기 기능만을 사용하기 위해선 읽기에 특화된 [tiffloader](https://github.com/MalcolmMcLean/tiffloader){:target="_blank"}도 상당히 쓸만하다.

![image](/images/2025-03-09/tiffloader_Bs64_Q.png){: .align-center}

```text
TIFF loader, by Malcolm McLean

Meant to be a pretty comprehensive, one file, portable TIFF reader
We just read everything in as 8 bit RGBs.

Current limitations - no JPEG, no alpha, a few odd formats still
unsupported
No sophisticated colour handling

Free for public use
Acknowlegements, Lode Vandevenne for the Zlib decompressor
```

이 라이브러리는 **C 파일 하나**로 구성된 깔끔한 구성의 빠른 라이브러리이다.\
심지어 특별한 라이센스도 없어서 법률적 부담도 없다.

그런데, 이 라이브러리는 그냥 쓰기엔 손을 좀 대야 할 내용들이 많다.\
위 문구에도 나와있듯이, 지원되지 않는 포맷도 있지만, 오류들이 곳곳에 숨어있다.

수정된 내용을 일일이 열거하기엔 양이 너무 많고, 몇 개만 열거해본다.

## unsigned char* floadtiffwhite()

```c
for(i=0;i< *width * *height;i++)
{
    rgb[i*3] = buff[i*4] + 255 - buff[i*4+3];
    rgb[i*3+1] = buff[i*4+1] + 255 - buff[i*4+3];
    rgb[i*3+2] = buff[i*4+2] + 255 - buff[i*4+3]; 
}
```

처음 봤을 때 한참을 들여다봤던 부분이다.\
`buff[i*4+3]`에는 불투명도가 저장돼있는데, 이게 이런 식으로 계산되면 안 되는데...?

$$\begin{align}
{Color}_{final}=Color\times\frac{alpha}{255}+Bkgr\times\frac{255-alpha}{255}
\end{align}$$

이 코드에서 의미하는 상황은 $$Bkgr = 255$$ 이므로...

$$\begin{align}
{Color}_{final}=Color\times\frac{alpha}{255}+255-alpha
\end{align}$$

따라서, 아래와 같이 수정해야 의도에 맞게 동작한다.

```c
for (i = 0; i < *width * *height; i++)
{
    const int alpha = buff[i * 4 + 3];
    rgb[i * 3] = (unsigned char)(buff[i * 4] * alpha / 255 + 255 - alpha);
    rgb[i * 3 + 1] = (unsigned char)(buff[i * 4 + 1] * alpha / 255 + 255 - alpha);
    rgb[i * 3 + 2] = (unsigned char)(buff[i * 4 + 2] * alpha / 255 + 255 - alpha);
}
```

## unsigned char *floadtiff()

```c
if (enda == 'I' && endb == 'I')
{
    type = LITTLE_ENDIAN;
}
else if (endb == 'M' && endb == 'M')
{
    type = BIG_ENDIAN;
}
else
    goto parse_error;
```

너무나 사소한 오타가 있었다.\
웬만한 IDE에선 다 경고할텐데...

```c
if (enda == 'I' && endb == 'I')
    type = LITTLE_ENDIAN;
else if (enda == 'M' && endb == 'M')
    type = BIG_ENDIAN;
else
    goto parse_error;
```

## static int header_fixupsections()

TIFF 파일의 헤더를 읽은 뒤, 실제 처리할 수 없는 경우를 미리 걸러대도록 수정했다.\
이런 부분은 만들어두셨어도 됐을 거 같은데...

```c
// BLUEnLIVE: predictor가 3이면 처리 불가함
if (header->predictor < 1 || header->predictor > 2)
    return -1;

// planer == 2인데, tiled인 경우 처리 불가
if (header->planarconfiguration == 2 && header->tilewidth > 0 && header->tileheight > 0)
    return -1;
```

## static int paltorgba()

```c
if (index >= 0 && index < header->Ncolormap)
{
    rgba[0] = header->colormap[index * 3];
    rgba[1] = header->colormap[index * 3 + 1];
    rgba[2] = header->colormap[index * 3 + 2];
}
```

RGBA를 다루는 부분인데, `rgba[3] = 255;`가 누락됐다...\
아니, 이건 좀 너무한 거 아닌가요...?

## static int readintsample()

```c
if (header->sampleformat[sample_index] == SAMPLEFORMAT_UINT)
```

Sample Format을 UNIT 대신 INT로 지정해놓은 파일들이 종종 보인다.\
이를 정상적으로 처리하지 못해서 아래와 같이 수정.

```c
if ((header->sampleformat[sample_index] == SAMPLEFORMAT_UINT) ||
    (header->sampleformat[sample_index] == SAMPLEFORMAT_INT))
```

## static double memreadieee754()

이 코드는 다양한 환경을 염두에 두고 있다.\
그 환경 중에는 IEEE 754를 처리하지 못하는 시스템도 포함하고 있다.\
이 관점이 재미있는 것은, C/C++ 언어의 표준에서는 IEEE 754를 강제하지 않기 때문이다.

하지만, 내가 사용하는 환경(Visual C++)에서 이러한 고려는 불필요하다.\
따라서 아래와 같이 과감하게 수정.

```c
static double memreadieee754(unsigned char* buff, int bigendian)
{
    unsigned long long tempd = 0;
    if (bigendian)
        tempd = ((unsigned long long)buff[0] << 56) | ((unsigned long long)buff[1] << 48) |
                ((unsigned long long)buff[2] << 40) | ((unsigned long long)buff[3] << 32) |
                ((unsigned long long)buff[4] << 24) | ((unsigned long long)buff[5] << 16) |
                ((unsigned long long)buff[6] << 8)  | (unsigned long long)buff[7];
    else
        tempd = ((unsigned long long)buff[7] << 56) | ((unsigned long long)buff[6] << 48) |
                ((unsigned long long)buff[5] << 40) | ((unsigned long long)buff[4] << 32) |
                ((unsigned long long)buff[3] << 24) | ((unsigned long long)buff[2] << 16) |
                ((unsigned long long)buff[1] << 8)  | (unsigned long long)buff[0];

    return *(double*)&tempd;
}
```

## static float memreadieee754f16()

앞에서 언급한 접근법은 다른 면에서 굉장히 유용하기도 하다.

TIFF에서 다루는 데이터 중에 Half-precision floating-point (16비트 float)가 있다.\
이 포맷을 Visual C++에서 다루는 것이 그리 녹록하지는 않다.

처리할 수 있는 데이터에 이 float16을 추가하면서, 이 형식을 읽을 수 있는 함수를 추가했다.

```c
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
