---
layout: single
title: "한/글(HWPX) 파일 압축기(HIS) 4.65 업데이트"
date: 2025-3-8 23:35:00 +0900
categories:
  - MyProgram
---

잊혀질만 하면 업데이트하던 한/글 파일 압축기를 이번에도 정말 오랜만에(**2년**만에... ㄷㄷㄷ) 업데이트했다.\
우리나라 특성상 이 프로그램을 완전히 벗어나는 건 쉽지 않다.

![image](</images/2025-03-08/hwpx_Bs64_Q.png>){: .align-center}
*드디어 TIFF를 지원!*

읽고 압축할 수 있는 파일 포맷에 TIFF를 추가했다.\
이를 위해 [LibTIFF](https://gitlab.com/libtiff/libtiff/){:target="_blank"}보다 가볍고, 읽기 기능에 특화된 [tiffloader](https://github.com/MalcolmMcLean/tiffloader){:target="_blank"}를 사용했다.

이전과 동일하게, 한/글 표준문서(∗.hwpx)와 HWPML 2.x(∗.hml)만 압축할 수 있다.\
굳이 예전 한/글 파일(∗.hwp)을 압축하려면 한/글 표준문서(hwpx)로 다시 저장해서 처리하면 된다.

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

이 프로그램은 아래 링크에서 다운받을 수 있으며, **avx2**가 지원되는 CPU에서만 동작한다.

<div style="text-align: center;" markdown="1">
[Download HWPX Image Shrinker v4.65.rar](</attachment/2025-03-08/HWPX Image Shrinker v4.65.rar>){: .btn .btn--info .btn--x-large}
<br>password꞉ <span style="color: red; font-size: 1.5em;"><b>teus.me</b></span>
</div>

## 히스토리

* 2024.3.8꞉ v4.65
  * 처리 대상 이미지 포맷에 **TIFF** 추가
  * libzip을 1.11.2로 업데이트 (2024.12.22)
  * JpegQ를 상하 키보드로 조절할 수 있도록 수정
