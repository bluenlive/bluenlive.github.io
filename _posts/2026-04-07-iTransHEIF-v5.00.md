---
layout: single
title: "아주 빠른 HEIF 이미지 변환기 iTrans HEIF 5.00 업데이트"
date: 2026-4-7 20:54:00 +0900
categories:
  - iDevice
---

## 소개 및 다운로드

애플의 iOS 11부터 적용되기 시작한 HEIF는 이제 꽤 널리 확산되었다.\
[윈도우 11에서도 HEIF 확장](https://www.microsoft.com/store/productId/9PMMSR1CGPWG?ocid=pdpshare)을 다운받으면 간단히 볼 수 있고, [반디뷰](https://kr.bandisoft.com/bandiview/)에서도 이를 지원한다.

하지만, 그래도 아직은 **jpeg/png로 변환**해야 하는 경우가 종종 발생한다.

[libheif](https://github.com/strukturag/libheif) 및 [libde265](https://github.com/strukturag/libde265)를 활용해서 **더더욱 빨라진** HEIF→JPEG/PNG 변환기를 공개한다.\
물론 [Windows 11의 HEIF 확장](https://www.microsoft.com/store/productId/9PMMSR1CGPWG?ocid=pdpshare) 및 [HEVC 확장](https://www.microsoft.com/store/productId/9NMZLZ57R3T7?ocid=pdpshare)을 활용하는 기능도 여전히 제공한다.\
오픈소스 프로그램만을 활용하며, 다중코어를 활용해 빠르게 변환하는 기존의 기능도 더욱 안정화시켰다.

![image](/images/2026-04-07e/iTransHEIF_okl_s64_Q.webp)

이 프로그램은 이전 버전과 마찬가지로 HEIF를 jpeg/png로 변환해주며 **성능도 안정성도 더욱 향상되었다**.

{: .bluebox-gray}
1. [libheif](https://github.com/strukturag/libheif) 및 [libde265](https://github.com/strukturag/libde265)를 활용하여 **윈도우 확장을 설치하지 않아도** 변환 가능
   - WIC(윈도우 확장)를 이용하는 것보다 읽는 속도가 **더 빠름**
2. **\*\*ICC Profile\*\***, **\*\*Exif\*\*** 등을 모두 제대로 읽어내어 변환
3. 파일의 시간 정보를 Exif와 동일하게 맞춰줌
4. 타일 방식이 아니라 AniGIF처럼 여러 장의 이미지가 들어있는 경우 각각의 이미지 파일로 추출
5. [libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo) 및 [zlib-ng](https://github.com/zlib-ng/zlib-ng)이 적용된 [libpng](https://github.com/glennrp/libpng)를 활용하여 아주 빠른 속도로 저장
6. **png 파일에도 Exif 정보를 함께 저장**
7. 깊이 정보가 함께 있는 아이폰/아이패드 사진이라면 **깊이 정보**도 **별도의 파일**로 저장

변환기는 아래 링크에서 다운받을 수 있으며, 별도의 설치 프로그램 따위는 없다.

{% include bnl_download-box.html
   file="/attachment/2026-04-07e/iTransHEIF_v5.00.rar"
   description="64bit only"
   password="teus.me" %}

## 히스토리

{: .bluebox-history}
- 2026.4.7꞉ v5.00
  - 오픈소스 라이선스 표시 기능 추가
  - 화면 색상 튜닝
  - [libheif](https://github.com/strukturag/libheif) 및 [libde265](https://github.com/strukturag/libde265) 추가 적용
    - WIC에서 HEIF 지원이 제대로 되지 않는 경우를 대비하여, **자체적으로 HEIF 처리**를 위해 추가로 적용함
    - WIC보다 읽는 속도가 더 빠름
  - 내부 어플리케이션/라이브러리 업데이트 및 변경
    - [FFmpeg](http://ffmpeg.org/download.html)을 8.1\[gyan.dev\]로 업데이트
    - [MP4Box](https://gpac.wp.imt.fr/)를 gpac-26.02-rev0으로 업데이트
    - [libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo)를 3.1.90 (3.2 beta1) 업데이트(Mar 28, 2026)
    - [libpng](https://github.com/pnggroup/libpng)를 1.8.0.git(Merge v1.6.56, Feb 11, 2026)으로, [zlib-ng](https://github.com/zlib-ng/zlib-ng)를 2.3.3(Feb 4, 2026)으로 업데이트
