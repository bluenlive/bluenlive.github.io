---
layout: single
title: "사진 정리 툴 FPO(Family Photo Organizer) 9.01 업데이트"
categories:
  - MyProgram
---


이제 DSLR 이외의 수많은 장비들이 카메라의 자리를 대신하고 있다.  
이러다보니, 여행을 가서 찍은 사진을 모아보면 의외로 **정리가 쉽지 않다**.

온라인/모바일 환경에선 정렬을 **Exif 촬영일자 순**으로 하는 경우가 많다.  
그런데, PC에선 **파일명 순**인 경우가 일반적이다.  
이런 식이다보니 촬영시간 순서는 알기 힘들고 **카메라 기종 순**으로 파일을 보게 되는 경우가 대부분이다.

![image](/images/2024-01-28/pics1.png){: .align-center}
*피쳐폰 - 똑딱이 - 작티 순 정렬...*

FPO는 HEIF/JPEG의 Exif 정보 중 촬영일자 정보를 읽어 **파일명을 수정**하고, 최대한 **파일 크기를 줄여준다**.  
[mozjpeg](https://github.com/mozilla/mozjpeg/){:target="_blank"}를 활용해서 파일 크기를 더 줄이고, 추가로 **resample**을 적용해서 사진 크기도 축소시켜준다.  
또한, 사진과 함께 저장된 PNG, WebP, avi, mp4 등의 다양한 미디어 자료들도 함께 파일명을 수정해준다.

![image](/images/2024-01-28/pics2.png){: .align-center}
*촬영날짜/시간 순 정렬 완료!*

이 프로그램의 상세한 기능은 아래와 같다.

<div style="background-color: #fefeb8; padding: 10px; border: 1px dashed #f3c534; font-size: 0.95em; margin-bottom: 1.2em;" markdown="1">
**멀티코어 환경에서 이미지를 동시에 변환**(v5.1a부터)
- JPEG 파일을 읽을 때 노이즈(JPEG Artifacts)를 제거하는 옵션 추가([jpeg-quantsmooth](https://github.com/ilyakurdyukov/jpeg-quantsmooth){:target="_blank"} 적용)
- Exif에 기록된 촬영일자 순으로 파일명 수정
- Exif 정보가 없는 경우 파일 날짜 활용
- 텍스트 데이터를 통한 Exif 생성
- JPEG 외에 PNG / GIF / WebP / MKV / MP4 / MOV / AVI까지 파일명 수정하며,  
PNG / WebP / MP4 / MOV / MKV는 파일 내에 태깅된 날짜 정보 활용함
- 사용자 선택시 PNG를 JPEG로 변환
- PNG/JPEG 재압축 및 리사이징
- Exif 날짜를 촬영일자로 수정
- 파일 날짜를 Exif 날짜로 변경
- 옵션 지정시 파일명에서 날짜 및 시간 추출
- jpeg 라이브러리로 [mozjpeg](https://github.com/mozilla/mozjpeg/){:target="_blank"} 사용
- 유니코드 완벽 지원
</div>

![image](/images/2024-01-28/FPO.png){: .align-center}

이 프로그램은 아래 링크에서 다운받을 수 있다.

<div style="text-align: center;" markdown="1">
[Download FPO_v9.01.rar](/attachment/2024-01-28/FPO_v9.01.rar){: .btn .btn--info .btn--x-large}
<br>password꞉ <span style="color: red; font-size: 1.5em;"><b>teus.me</b></span>
</div>

## 히스토리

* 2024.1.28꞉ v9.01 공개
  * 인텔 IPP 라이브러리를 사용하도록 수정 (이로 인해 x86 지원 종료)
  * JPEG comment를 제대로 읽고 쓰지 못하는 오류 수정
  * jpeg-quantsmooth 오류 수정꞉ 세로 크기가 DCTSIZE의 배수가 아닐 때 이미지가 깨지는 오류
  * 파일에서 날짜를 읽을 때 최근에 변경된 날짜를 읽도록 수정
  * libpng를 Jan 25, 2024(1.6.41)로, zlib-ng를 2.1.6(Jan 11, 2024)으로 업데이트
