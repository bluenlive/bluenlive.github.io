---
layout: single
title: "사진 정리 툴 FPO(Family Photo Organizer) 10.00 업데이트"
date: 2026-4-7 08:45:00 +0900
categories:
  - MyProgram
---

이제 DSLR 이외의 수많은 장비들이 카메라의 자리를 대신하고 있다.  
이러다보니, 여행을 가서 찍은 사진을 모아보면 의외로 **정리가 쉽지 않다**.

온라인/모바일 환경에선 정렬을 **Exif 촬영일자 순**으로 하는 경우가 많다.  
그런데, PC에선 **파일명 순**인 경우가 일반적이다.  
이런 식이다보니 촬영시간 순서는 알기 힘들고 **카메라 기종 순**으로 파일을 보게 되는 경우가 대부분이다.

![image](/images/2026-04-07a/pics1_B_Q.webp)
*피쳐폰 - 똑딱이 - 작티 순 정렬...*

FPO는 HEIF/JPEG의 Exif 정보 중 촬영일자 정보를 읽어 **파일명을 수정**하고, 최대한 **파일 크기를 줄여준다**.  
[mozjpeg](https://github.com/mozilla/mozjpeg/)를 활용해서 파일 크기를 더 줄이고, 추가로 **resample**을 적용해서 사진 크기도 축소시켜준다.  
또한, 사진과 함께 저장된 PNG, WebP, avi, mp4 등의 다양한 미디어 자료들도 함께 파일명을 수정해준다.

![image](/images/2026-04-07a/pics2_B_Q.webp)
*촬영날짜/시간 순 정렬 완료!*

이 프로그램의 상세한 기능은 아래와 같다.

{: .bluebox-yellow}
- **멀티코어 환경에서 이미지를 동시에 변환**(v5.1a부터)
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
- jpeg 라이브러리로 [mozjpeg](https://github.com/mozilla/mozjpeg/) 사용
- 유니코드 완벽 지원

![image](/images/2026-04-07a/FPO_okl_s64_Q.webp)

이 프로그램은 아래 링크에서 다운받을 수 있다.

{% include bnl_download-box.html
   file="/attachment/2026-04-07a/FPO_v10.00.rar"
   description="64bit only"
   password="teus.me" %}

## 히스토리

{: .bluebox-history}
- 2026.4.7: v10.00 공개
  - 오픈소스 라이선스 표시 기능 추가
  - [libheif](https://github.com/strukturag/libheif) 및 [libde265](https://github.com/strukturag/libde265) 추가 적용
    - WIC에서 HEIF 지원이 제대로 되지 않는 경우를 대비하여, **자체적으로 HEIF 처리**를 위해 추가로 적용함
    - WIC보다 읽는 속도가 더 빠름
  - [jpeg-quantsmooth](https://github.com/ilyakurdyukov/jpeg-quantsmooth) 제거
  - libpng(x64)를 1.8.0.git(Merge v1.6.56, Feb 11, 2026)으로, zlib-ng를 2.3.3(Feb 4, 2026)으로 업데이트
  - HEVC WIC 주소 수정
