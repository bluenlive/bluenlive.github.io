---
layout: single
title: "UTF-8 포맷을 빠르게 감지하는 방법"
date: 2025-2-15 15:00:00 +0900
categories:
  - algorithm
---

<div style="background-color: #fedec7; padding: 10px; border: 1px dashed #fe8943; margin-bottom: 1.2em;"><p style="text-align: center; margin-bottom: 0;"><span style="font-size: 1.111em;"><b>
<span style="color: #980000;">파이썬으로 텍스트 파일을 읽다 문제가 터져서 빡치는 바람에 쓴 글.</span>
</b></span></p></div>

## 사소한 시작

발단은 사소했다.\
[Spetral Python](https://www.spectralpython.net/){:target="_blank"}이라는 라이브러리를 사용하는데, 파일을 읽지 못하고 예외가 발생했다.

Spectral 데이터는 텍스트 포맷의 ENVY 파일과 바이너리 포맷으로 구성되어 있다.\
이 중 ENVY 파일을 읽을 때 문제가 발생한 것.\
단순하기 짝이 없는 텍스트 파일인데 왜 그런가 보니 이 라이브러리는 **ANSI** 포맷만 지원하는 것이다.\
그리고, 내가 가진 ENVY 파일은 **UTF-8**로 저장되어 있었던 것.

문제 자체는 잠깐의 빡침 외에는 별 일 없이 해결되었다.\
ANSI 포맷으로 변환하는 것으로 간단하게 종료.

![image](</images/2025-02-15a/UTF-8.jpg>){: .align-center}
*AI로 만들어본 UTF-8 이미지*

그런데, 이 문제는 사실 21세기에 텍스트 파일을 다루는 거의 모든 영역에서 발생할 수 있는 문제이다.\
웹 쪽에서는 **UTF-8**이 표준이 되었지만, 생각보다 많은 라이브러리들은 ANSI 포맷만 지원한다.\
여기에 Visual C++는 놀랍게도 UTF-16을 더 효율적으로 지원하도록 만들어졌다.\
(그런데 또, Visual Studio Code는 UTF-8을 기본으로 사용한다.)\
이런 상황에서, 텍스트 파일을 효과적으로 다루기 위해서는 각 포맷을 이해하고 적절히 처리할 필요가 있다.

## UTF-8 감지가 어렵나?

다른 포맷들과는 달리 UTF-8은 특별한 점이 있다.\
데이터를 스캔하는 것만으로 UTF-8 포맷 여부를 확인할 수 있다는 점이다.\
모든 포맷을 다 지원하지 않더라도, 최소한 ANSI와 UTF-8 정도는 쉽게 처리할 수 있어야 한다는 얘기다.

깃허브를 조금만 뒤져보면 이 점에 열정을 쏟은 사람들을 쉽게 볼 수 있다.\
[lemire/fastvalidate-utf-8](https://github.com/lemire/fastvalidate-utf-8){:target="_blank"}는 오래 전부터 이런 작업을 했었다.\
그리고, 이미 이것도 느리다고 SIMD를 사용한 라이브러리들도 나왔다.\
[zwegner/faster-utf8-validator](https://github.com/zwegner/faster-utf8-validator){:target="_blank"}에서는 SSE4.1/AVX2를 사용하여 더 빠르게 UTF-8을 검증한다.\
이것도 부족한지 [simdutf/simdutf](https://github.com/simdutf/simdutf){:target="_blank"}에서는 수많은 SIMD 기술들을 다 동원한다.

즉, UTF-8 검증은 이제 어려운 기술도 아니고, 뭔가를 스스로 만들어야 되는 기술도 아니다.\
그런데, **파이썬은 대체 왜 저런 수준**인 걸까...

---

덧. 이 처리를 적용할 때 컴파일러 설정에서 AVX2가 활성화됐는지 여부는 `#ifdef __AVX2__`로 확인할 수 있다.\
그런데, SSE2는 `#ifdef __SSE2__`로 확인이 잘 안 된다.\
대신, `#if (_M_IX86_FP >= 2) || defined(__SSE2__) || defined(_WIN64)`로 확인해야 한다.
