---
layout: single
title: "한/글(HWPX) 파일 압축기(HIS) 4.81 업데이트"
date: 2026-2-13 11:47:00 +0900
categories:
  - MyProgram
---

잊혀질만 하면 업데이트하던 한/글 파일 압축기를 이번에도 정말 오랜만에 업데이트했다.\
우리나라 특성상 이 프로그램을 완전히 벗어나는 건 쉽지 않다.

![image](/images/2026-02-13c/HIS_B_okl_s64_Q.png){: .align-center}
*드디어 TIFF를 지원!*

읽고 압축할 수 있는 파일 포맷에 TIFF를 추가했다.\
이를 위해 [LibTIFF](https://gitlab.com/libtiff/libtiff/){:target="_blank"}보다 가볍고, 읽기 기능에 특화된 [tiffloader](https://github.com/MalcolmMcLean/tiffloader){:target="_blank"}를 사용했다.

이전과 동일하게, 한/글 표준문서(∗.hwpx)와 HWPML 2.x(∗.hml)만 압축할 수 있다.\
굳이 예전 한/글 파일(∗.hwp)을 압축하려면 한/글 표준문서(hwpx)[^1]로 다시 저장해서 처리하면 된다.

이 버전에서 수정된 사항들은 아래와 같다.

{: .bluebox-blue}
- **TIFF** 압축 기능 추가  
기존의 BMP와 동일한 규칙으로 png와 jpeg 변환을 알아서 선택하여 적절한 방식으로 재압축함  
PNGquant를 선택하는 자동 옵션도 있음
- 64비트 버전만 배포
- JpegQ 조절시 상하 키보드로도 조절 가능하도록 수정

이 프로그램은 아래 링크에서 다운받을 수 있으며, **AVX2**가 지원되는 CPU[^2]에서만 동작한다.

{% include bluenlive/download-box.html
   file="/attachment/2026-02-13c/HWPX_Image_Shrinker_v4.81.rar"
   description="64bit only"
   password="teus.me" %}

## 히스토리

{: .bluebox-history}
- 2025.3.8꞉ v4.65
  - 처리 대상 이미지 포맷에 **TIFF** 추가
  - [libzip](https://github.com/nih-at/libzip/){:target="_blank"}을 1.11.2(2024.12.22)로 업데이트
  - JpegQ를 상하 키보드로 조절할 수 있도록 수정

- 2025.11.6꞉ v4.70
  - 파일명에 `%` 가 들어있는 경우에도 제대로 동작하도록 수정
  - 툴팁 색을 Oklab 기반으로 튜닝
  - 내부 라이브러리 업데이트
    - [mozJPEG](https://github.com/mozilla/mozjpeg){:target="_blank"}을 v5.0.0.dev(Jun 24, 2025)로 업데이트
    - [libpng](https://github.com/pnggroup/libpng){:target="_blank"}를 1.6.50(July 2, 2025)로 업데이트
    - [zlib-ng](https://github.com/zlib-ng/zlib-ng){:target="_blank"}를 2.2.5(Aug 7, 2025)으로 업데이트
    - [libimagequant](https://pngquant.org/){:target="_blank"}를 4.5.0으로 업데이트 (2025.7.30)

- 2025.12.5꞉ v4.76
  - Taskbar progress 와 더불어 progress bar도 함께 표시하도록 UI 수정
  - 생성되는 임시 배치 파일을 가독성을 높이도록 수정
  - 임시 로그 파일을 markdown 형식에 부합하도록 수정
  - HWPML 파일 처리시 zlib으로 압축된 파일을 잘못 처리하던 오류 수정
  - 내부 라이브러리 업데이트
    - [libpng](https://github.com/pnggroup/libpng){:target="_blank"}를 1.8.0.git(Dec 4, 2025)으로 업데이트
    - [zlib-ng](https://github.com/zlib-ng/zlib-ng){:target="_blank"}를 2.3.2(dev 4, 2025)로 업데이트
    - [libzip](https://github.com/nih-at/libzip/){:target="_blank"}을 1.11.4(2025.11.7)로 업데이트

- 2026.2.13꞉ v4.81
  - UI 미세 튜닝
    - 탭 오더 조절
    - `avx2` 문구를 `AVX2`로 변경
  - 리샘플링 라이브러리 전면 재작성
    - 인텔 IPP 라이브러리 배제
    - 리샘플링 라이브러리를 SIMD로 직접 구현
      - CPU only, AVX2, AVX512 별로 각각 구현
    - 리샘플링 색공간을 sRGB, Linear, Oklab 3가지에서 선택 가능하도록 수정
  - HEIF/JPEG/PNG 에서 ICCP 처리시 64KB 이상인 경우도 정상 처리하도록 수정
  - 내부 라이브러리 업데이트
    - [libzip](https://github.com/nih-at/libzip/){:target="_blank"}를 [libzip-win-build](https://github.com/kiyolee/libzip-win-build){:target="_blank"}로 교체 및 1.11.4-p1로 업데이트  
    - [libpng](https://github.com/pnggroup/libpng){:target="_blank"}를 1.8.0.git(Feb 11, 2026)으로 업데이트
    - [zlib-ng](https://github.com/zlib-ng/zlib-ng){:target="_blank"}를 2.3.3(Feb 4, 2026)로 업데이트
    - [libimagequant](https://pngquant.org/){:target="_blank"}를 4.5.0(Feb 11, 2026 추가 반영)으로 업데이트 (2026.2.13)

[^1]: 이 포맷이 한글과 컴퓨터에서 권장하는 포맷이기도 하고, 저장 속도도 빠르며 저장 안정성도 높음
[^2]: 일부 구형 x64 CPU에서는 AVX2를 지원하지 않음에 유의할 것
