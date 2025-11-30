---
layout: single
title: "아주 빠른 HEIF 이미지 변환기 iTrans HEIF 4.04 업데이트"
date: 2024-5-1
last_modified_at: 2024-5-1
categories:
  - iDevice
---

<div style="border-style: dashed; border-width: 1px; border-color: #79a5e4; background-color: #dbe8fb; padding: 10px;"><p style="text-align: center; margin-bottom: 0;"><span style="font-size: 1.111em;"><b><a href="/idevice/iTransHEIF-v4.12/">새 버전</a>이 나왔습니다. <a href="/idevice/iTransHEIF-v4.12/">새 버전</a>을 사용해주시기 바랍니다.</b></span></p></div><p><br /></p>

## 소개 및 다운로드

애플의 iOS 11부터 적용되기 시작한 HEIF는 이제 꽤 널리 확산되었다.  
[윈도우 10/11에서도 뷰어를 다운](https://www.microsoft.com/store/productId/9PMMSR1CGPWG?ocid=pdpshare){:target="_blank"}받으면 간단히 볼 수 있고, [반디뷰](https://kr.bandisoft.com/bandiview/){:target="_blank"}에서도 이를 지원한다.

하지만, 그래도 아직은 **jpeg/png로 변환**해야 하는 경우가 종종 발생한다.

[Windows 10/10의 HEIF 확장](https://www.microsoft.com/store/productId/9PMMSR1CGPWG?ocid=pdpshare){:target="_blank"} 및 [HEVC 확장](https://www.microsoft.com/store/productId/9NMZLZ57R3T7?ocid=pdpshare){:target="_blank"}을 활용해서 **더욱 빨라진** HEIF→JPEG/PNG 변환기를 공개한다.  
오픈소스 프로그램만을 활용하며, 다중코어를 활용해 빠르게 변환하는 기존의 기능도 더욱 안정화시켰다.

![image](/images/2024-02-07/iTransHEIF_B_Q.png){: .align-center}

이 프로그램은 이전 버전과 마찬가지로 HEIF를 jpeg/png로 변환해주며 **성능도 안정성도 더욱 향상되었다**.

{: .bluebox-gray}
1. **ICC Profile**, **Exif** 등을 모두 제대로 읽어내어 변환
2. 파일의 시간 정보를 Exif와 동일하게 맞춰줌
3. 타일 방식이 아니라 AniGIF처럼 여러 장의 이미지가 들어있는 경우 각각의 이미지 파일로 추출
4. [libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo){:target="_blank"} 및 [zlib-ng](https://github.com/zlib-ng/zlib-ng){:target="_blank"}이 적용된 [libpng](https://github.com/glennrp/libpng){:target="_blank"}를 활용하여 아주 빠른 속도로 저장
5. **png 파일에도 Exif 정보를 함께 저장**
6. 깊이 정보가 함께 있는 아이폰/아이패드 사진이라면 **깊이 정보**도 **별도의 파일**로 저장

변환기는 아래 링크에서 다운받을 수 있으며, 별도의 설치 프로그램 따위는 없다.

{% include bluenlive/download-box.html
   file="/attachment/2024-02-07/iTransHEIF_v4.04.rar"
   description="64bit only"
   password="teus.me" %}

## 히스토리

- 2024.2.7꞉ v4.03
  - 스레드 생성 코드 개선
  - [FFmpeg](http://ffmpeg.org/download.html){:target="_blank"}을 6.1.1\[gyan.dev\]로 업데이트
  - [libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo){:target="_blank"}를 3.0.2로 업데이트(Jan 23, 2024)
  - [libpng](https://github.com/pnggroup/libpng){:target="_blank"}를 1.6.42(Jan 30, 2024)로, [zlib-ng](https://github.com/zlib-ng/zlib-ng){:target="_blank"}를 2.1.6(Jan 11, 2024)으로 업데이트
  - [HEIF 확장](https://www.microsoft.com/store/productId/9PMMSR1CGPWG?ocid=pdpshare){:target="_blank"} 및 [HEVC 확장](https://www.microsoft.com/store/productId/9NMZLZ57R3T7?ocid=pdpshare){:target="_blank"} 링크 주소 수정

- 2024.5.1꞉ v4.04
  - 내부적으로 시간 계산시 `GetTickCount64()`를 완전히 배제
  - [FFmpeg](http://ffmpeg.org/download.html){:target="_blank"}을 7.0\[gyan.dev\]로 업데이트
  - [libpng](https://github.com/pnggroup/libpng){:target="_blank"}를 1.6.43(Feb 23, 2024)으로 업데이트
  - [mp4box](https://github.com/gpac/gpac){:target="_blank"}를 2.4(April 17, 2024)로 업데이트
