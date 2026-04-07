---
layout: single
title: "한/글(HWPX) 파일 압축기(HIS) 5.00 업데이트"
date: 2026-4-7 13:05:00 +0900
categories:
  - MyProgram
---

잊혀질만 하면 업데이트하던 한/글 파일 압축기를 이번에도 정말 오랜만에 업데이트했다.\
우리나라 특성상 이 프로그램을 완전히 벗어나는 건 쉽지 않다.

![image](/images/2026-04-07b/HWPX_okl_s64_Q.webp)

내부적으로 너무 느려 실용성이 없는 [zopflipng](https://github.com/google/zopfli)를 [OxiPNG](https://github.com/oxipng/oxipng)로 교체했다.\
또한, 라이선스 이슈가 우려되는 [libimagequant](https://github.com/ImageOptim/libimagequant)를 [ExoQuant](https://github.com/exoticorn/exoquant-rs)로 교체했다.

이전과 동일하게, 한/글 표준문서(∗.hwpx)와 HWPML 2.x(∗.hml)만 압축할 수 있다.\
굳이 예전 한/글 파일(∗.hwp)을 압축하려면 한/글 표준문서(hwpx)[^1]로 다시 저장해서 처리하면 된다.

이 프로그램은 아래 링크에서 다운받을 수 있으며, **AVX2**가 지원되는 CPU[^2]에서만 동작한다.

{% include bnl_download-box.html
   file="/attachment/2026-04-07b/HWPX_Image_Shrinker_v5.00.rar"
   description="64bit only"
   password="teus.me" %}

## 히스토리

{: .bluebox-history}
- 2026.4.7꞉ v5.00
  - 오픈소스 라이선스 표시 기능 추가
  - [zopflipng](https://github.com/google/zopfli)를 [OxiPNG](https://github.com/oxipng/oxipng)로 교체
  - [libimagequant](https://github.com/ImageOptim/libimagequant)를 [ExoQuant](https://github.com/exoticorn/exoquant-rs)로 교체
  - libpng(x64)를 1.8.0.git(Merge v1.6.56, Feb 11, 2026)으로, zlib-ng를 2.3.3(Feb 4, 2026)으로 업데이트

[^1]: 이 포맷이 한글과 컴퓨터에서 권장하는 포맷이기도 하고, 저장 속도도 빠르며 저장 안정성도 높음
[^2]: 일부 구형 x64 CPU에서는 AVX2를 지원하지 않음에 유의할 것
