---
layout: single
title: "media-autobuild_suite 빌드 실패 해결법"
date: 2025-10-28 15:45:00 +0900
categories:
  - ITTalk
---

[media-autobuild_suite](https://github.com/m-ab-s/media-autobuild_suite){:target="_blank"} 빌드를 실패했다가 해결했는데, 해결법을 까먹지 않으려 포스팅.

[ffmpeg](https://ffmpeg.org/){:target="_blank"}은 공개된 버전만으로도 엄청난 기능들을 제공하는 이 바닥 끝판왕이다.\
그런데, 직접 빌드해서 사용하면 한발짝 더 나가서 더 많은 기능을 사용할 수 있다.\
이 빌드를 손쉽게 할 수 있도록 도와주는 프로젝트가 바로 **media-autobuild_suite**이다.

그런데, 지원하는 라이브러리의 종류가 워낙에 많은데다, 빌드할 때마다 최신버전으로 업데이트를 하는 과정에서 빌드에 실패하는 경우가 종종 발생한다.\
빌드 실패 문구에도 그냥 **나중에 다시 시도**하라는 내용이 적혀있을 뿐이다.

이번에도 어김 없이(?) 오류가 발생했다.

```text
ERROR: lc3 >= 1.1.0 not found using pkg-config
```

빌드 디렉토리를 모두 깨끗하게 비우고 다시 시작해도 마찬가지였다.

## LC3 라이브러리만 다시 빌드

그런데, 이 경우는 LC3 라이브러리가 맞지 않아서 발생한 상황이다.\
아마도 빌드 과정에서 이전 버전이 컴파일되는 문제가 있는 것 같다.

이 때는 빌드 실패한 상태에서, 해당 라이브러리만 모두 지우고 다시 빌드하면 해결된다.\
지워야 할 파일/폴더는 다음과 같다.

``` text
media-autobuild_suite\build\liblc3* 폴더
media-autobuild_suite\local64\lib\liblc3.a 파일
```

## LC3 라이브러리 배제

그런데, LC3 라이브러리를 사용할 일이 없으므로 좀 더 화끈한 해결책을 쓸 수도 있다.\
처음 실행할 때 ffmpeg의 옵션을 입력받는데, 여기서 바로 LC3 라이브러리를 배제하는 것이다.\
하는 김에, 역시 사용하지 않는 **OpenH264** 라이브러리도 함께 배제하기로 했다.

``` text
--disable-libopenh264 --disable-lc3
```

이 항목은 첫 실행 이후에서는 **ffmpeg_options.txt** 파일에서 배제할 수도 있다.\
**build\ffmpeg_options.txt** 파일을 수정하면 된다.

``` text
--disable-liblc3
--disable-libopenh264
```
