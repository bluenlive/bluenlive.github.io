---
layout: single
title: "사진 정리 툴 FPO(Family Photo Organizer) 9.31 업데이트"
date: 2026-2-13 11:40:00 +0900
categories:
  - MyProgram
---

이제 DSLR 이외의 수많은 장비들이 카메라의 자리를 대신하고 있다.  
이러다보니, 여행을 가서 찍은 사진을 모아보면 의외로 **정리가 쉽지 않다**.

온라인/모바일 환경에선 정렬을 **Exif 촬영일자 순**으로 하는 경우가 많다.  
그런데, PC에선 **파일명 순**인 경우가 일반적이다.  
이런 식이다보니 촬영시간 순서는 알기 힘들고 **카메라 기종 순**으로 파일을 보게 되는 경우가 대부분이다.

![image](/images/2026-02-13b/pics1_B_Q.png){: .align-center}
*피쳐폰 - 똑딱이 - 작티 순 정렬...*

FPO는 HEIF/JPEG의 Exif 정보 중 촬영일자 정보를 읽어 **파일명을 수정**하고, 최대한 **파일 크기를 줄여준다**.  
[mozjpeg](https://github.com/mozilla/mozjpeg/){:target="_blank"}를 활용해서 파일 크기를 더 줄이고, 추가로 **resample**을 적용해서 사진 크기도 축소시켜준다.  
또한, 사진과 함께 저장된 PNG, WebP, avi, mp4 등의 다양한 미디어 자료들도 함께 파일명을 수정해준다.

![image](/images/2026-02-13b/pics2_B_Q.png){: .align-center}
*촬영날짜/시간 순 정렬 완료!*

이 프로그램의 상세한 기능은 아래와 같다.

{: .bluebox-yellow}
- **멀티코어 환경에서 이미지를 동시에 변환**(v5.1a부터)
- JPEG 파일을 읽을 때 노이즈(JPEG Artifacts)를 제거하는 옵션 추가([jpeg-quantsmooth](https://github.com/ilyakurdyukov/jpeg-quantsmooth){:target="_blank"} 적용)
- Exif에 기록된 촬영일자 순으로 파일명 수정
  - Exif 정보가 없는 경우 파일 날짜 활용
- Exif의 날짜 정보 활용
  - Exif 날짜를 촬영일자로 수정
  - 파일 날짜를 Exif 날짜로 변경
  - 사용자 선택시 파일명에서 날짜 및 시간 추출도 가능
- 텍스트 데이터를 통한 Exif 생성
- JPEG 외에 PNG / GIF / WebP / MKV / MP4 / MOV / AVI까지 파일명 수정하며,  
PNG / WebP / MP4 / MOV / MKV는 파일 내에 태깅된 날짜 정보 활용함
- 사용자가 선택하면 PNG를 JPEG로 변환 가능
- PNG/JPEG 재압축 및 리샘플링
  - 리샘플링 시 sRGB, Linear, Oklab 색공간 선택 가능
- jpeg 라이브러리로 [mozjpeg](https://github.com/mozilla/mozjpeg/){:target="_blank"} 사용
- 유니코드 완벽 지원

![image](/images/2026-02-13b/FPO_B_okl_s64_Q.png){: .align-center}

이 프로그램은 아래 링크에서 다운받을 수 있다.

{% include bluenlive/download-box.html
   file="/attachment/2026-02-13b/FPO_v9.31.rar"
   description="64bit only"
   password="teus.me" %}

## 히스토리

{: .bluebox-history}
- 2025.12.4: v9.24 공개
  - 아이콘 변경 및 UI 미세 튜닝
  - TOSS 아이디 후원을 [Buy Me A Coffee](https://buymeacoffee.com/bluenlive){:target="_blank"}로 변경
  - 파일명에서 날짜/시간 추출시 GMT 시간을 사용할 수 있는 옵션 추가
  - Exif 처리 시 Copyright, Artist, Software 항목을 삭제하는 기능 추가
  - 병렬 처리 개수 축소
    - 병렬 처리가 원활하게 처리되도록 스레드 개수 축소
    - quantsmooth 스레드 개수를 2개 이하로 제한하도록 수정
  - 리샘플링 라이브러리 전면 재작성
    - 인텔 IPP 라이브러리 배제
    - 리샘플링 라이브러리를 SIMD로 직접 구현
      - CPU only, AVX2, AVX512 별로 각각 구현
    - 리샘플링 색공간을 sRGB, Linear, Oklab 3가지에서 선택 가능하도록 수정
  - 이미지 라이브러리 업데이트
    - mozJPEG(x64) v5.0.0.dev 업데이트 (Jun 24, 2025)
    - libpng(x64) 1.8.0.git 업데이트 (Nov 25, 2025)
    - zlib-ng를 2.3.2(dev) 업데이트

- 2026.1.10: v9.27 공개
  - HEIF/JPEG/PNG 에서 ICCP 처리시 64KB 이상인 경우도 정상 처리하도록 수정
  - 이미지 라이브러리 업데이트
    - libpng(x64) 1.8.0.git 업데이트 (Dec 8, 2025)
    - zlib-ng를 2.3.2 업데이트 (Dec 8, 2025)

- 2026.2.13: v9.31 공개
  - UI 개선
    - Group box가 enable/disable 되도록 보강
  - 이미지 라이브러리 업데이트
    - [jpeg-quantsmooth](https://github.com/ilyakurdyukov/jpeg-quantsmooth){:target="_blank"}를 1.20260122으로 업데이트
      - 최대 스레드 추론 로직 개선 추가 반영
    - [libpng](https://github.com/pnggroup/libpng){:target="_blank"}를 1.8.0.git(Feb 11, 2026)으로 업데이트
    - [zlib-ng](https://github.com/zlib-ng/zlib-ng){:target="_blank"}를 2.3.3(Feb 4, 2026)로 업데이트
    - [libimagequant](https://pngquant.org/){:target="_blank"}를 4.5.0(Feb 11, 2026 추가 반영)으로 업데이트 (2026.2.13)
