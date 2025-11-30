---
layout: single
title: "아주 빠른 HEIF 이미지 변환기 iTrans HEIF 4.12 업데이트"
date: 2025-11-21 09:05:00 +0900
categories:
  - iDevice
---

## 소개 및 다운로드

애플의 iOS 11부터 적용되기 시작한 HEIF는 이제 꽤 널리 확산되었다.\
[윈도우 10/11에서도 뷰어를 다운](https://www.microsoft.com/store/productId/9PMMSR1CGPWG?ocid=pdpshare){:target="_blank"}받으면 간단히 볼 수 있고, [반디뷰](https://kr.bandisoft.com/bandiview/){:target="_blank"}에서도 이를 지원한다.

하지만, 그래도 아직은 **jpeg/png로 변환**해야 하는 경우가 종종 발생한다.

[Windows 10/10의 HEIF 확장](https://www.microsoft.com/store/productId/9PMMSR1CGPWG?ocid=pdpshare){:target="_blank"} 및 [HEVC 확장](https://www.microsoft.com/store/productId/9NMZLZ57R3T7?ocid=pdpshare){:target="_blank"}을 활용해서 **더욱 빨라진** HEIF→JPEG/PNG 변환기를 공개한다.\
오픈소스 프로그램만을 활용하며, 다중코어를 활용해 빠르게 변환하는 기존의 기능도 더욱 안정화시켰다.

![image](/images/2025-11-21b/iTransHEIF_B_okl_s64_Q.png){: .align-center}

이 프로그램은 이전 버전과 마찬가지로 HEIF를 jpeg/png로 변환해주며 **성능도 안정성도 더욱 향상되었다**.

{: .bluebox-gray}
1. **\*\*ICC Profile\*\***, **\*\*Exif\*\*** 등을 모두 제대로 읽어내어 변환
2. 파일의 시간 정보를 Exif와 동일하게 맞춰줌
3. 타일 방식이 아니라 AniGIF처럼 여러 장의 이미지가 들어있는 경우 각각의 이미지 파일로 추출
4. [libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo){:target="_blank"} 및 [zlib-ng](https://github.com/zlib-ng/zlib-ng){:target="_blank"}이 적용된 [libpng](https://github.com/glennrp/libpng){:target="_blank"}를 활용하여 아주 빠른 속도로 저장
5. **png 파일에도 Exif 정보를 함께 저장**
6. 깊이 정보가 함께 있는 아이폰/아이패드 사진이라면 **깊이 정보**도 **별도의 파일**로 저장

변환기는 아래 링크에서 다운받을 수 있으며, 별도의 설치 프로그램 따위는 없다.

{% include bluenlive/download-box.html
   file="/attachment/2025-11-21b/iTransHEIF_v4.12.rar"
   description="64bit only"
   password="teus.me" %}

## 히스토리

* 2025.11.21꞉ v4.12
  * UI 미세 조정
  * 파일명에 `%` 가 들어있는 경우에도 제대로 동작하도록 수정
  * 배치 파일 생성시 여러 줄로 생성해서 필요시 가독성 증대
  * TOSS 아이디 후원을 [Buy Me A Coffee](https://buymeacoffee.com/bluenlive){:target="_blank"}로 변경
  * [libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo){:target="_blank"}를 3.1.2로 업데이트(Aug 26, 2025)
  * [FFmpeg](http://ffmpeg.org/download.html){:target="_blank"}을 8.0\[gyan.dev\]으로 업데이트
  * [libpng](https://github.com/pnggroup/libpng){:target="_blank"}를 1.8.0.git(Nov 7, 2025)으로, [zlib-ng](https://github.com/zlib-ng/zlib-ng){:target="_blank"}를 2.3.0-rc2(Nov 18, 2025)로 업데이트
