---
layout: single
title: "한/글(HWPX) 파일 압축기(HIS) 4.70 업데이트"
date: 2025-11-6 23:22:00 +0900
categories:
  - MyProgram
---

잊혀질만 하면 업데이트하던 한/글 파일 압축기를 이번에도 정말 오랜만에(**2년**만에... ㄷㄷㄷ) 업데이트했다.\
우리나라 특성상 이 프로그램을 완전히 벗어나는 건 쉽지 않다.

![image](/images/2025-03-08/hwpx_B_okl_s64_Q.png){: .align-center}
*드디어 TIFF를 지원!*

읽고 압축할 수 있는 파일 포맷에 TIFF를 추가했다.\
이를 위해 [LibTIFF](https://gitlab.com/libtiff/libtiff/){:target="_blank"}보다 가볍고, 읽기 기능에 특화된 [tiffloader](https://github.com/MalcolmMcLean/tiffloader){:target="_blank"}를 사용했다.

이전과 동일하게, 한/글 표준문서(∗.hwpx)와 HWPML 2.x(∗.hml)만 압축할 수 있다.\
굳이 예전 한/글 파일(∗.hwp)을 압축하려면 한/글 표준문서(hwpx)[^1]로 다시 저장해서 처리하면 된다.

이 버전에서 수정된 사항들은 아래와 같다.

<div style="background-color: #DBE8FB; padding: 10px; border: 1px dashed #79A5E4; margin-bottom: 1.2em;"><p style="text-align: center; margin-bottom: 0;"><span style="font-size: 1.111em;">
<div markdown="1">
- **TIFF** 압축 기능 추가  
기존의 BMP와 동일한 규칙으로 png와 jpeg 변환을 알아서 선택하여 적절한 방식으로 재압축함  
PNGquant를 선택하는 자동 옵션도 있음
- 64비트 버전만 배포
- JpegQ 조절시 상하 키보드로도 조절 가능하도록 수정
</div>
</span></p></div>

이 프로그램은 아래 링크에서 다운받을 수 있으며, **avx2**가 지원되는 CPU[^2]에서만 동작한다.

{% include bluenlive/download-box.html
   file="/attachment/2025-03-08/HWPX_Image_Shrinker_v4.70.rar"
   password="teus.me" %}

## 히스토리

* 2025.3.8꞉ v4.65
  * 처리 대상 이미지 포맷에 **TIFF** 추가
  * [libzip](https://github.com/nih-at/libzip/){:target="_blank"}을 1.11.2로 업데이트 (2024.12.22)
  * JpegQ를 상하 키보드로 조절할 수 있도록 수정

* 2025.11.6꞉ v4.70
  * 파일명에 `%` 가 들어있는 경우에도 제대로 동작하도록 수정
  * 툴팁 색을 Oklab 기반으로 튜닝
  * 내부 라이브러리 업데이트
    * [mozJPEG](https://github.com/mozilla/mozjpeg){:target="_blank"}을 v5.0.0.dev(Jun 24, 2025)로 업데이트
    * [libpng](https://github.com/pnggroup/libpng){:target="_blank"}를 1.6.50(July 2, 2025)로, [zlib-ng](https://github.com/zlib-ng/zlib-ng){:target="_blank"}를 2.2.5(Aug 7, 2025)으로 업데이트
    * [libimagequant](https://pngquant.org/){:target="_blank"}를 4.5.0으로 업데이트 (2025.7.30)

[^1]: 이 포맷이 한글과 컴퓨터에서 권장하는 포맷이기도 하고, 저장 속도도 빠르며 저장 안정성도 높음
[^2]: 일부 구형 x64 CPU에서는 avx2를 지원하지 않음에 유의할 것
