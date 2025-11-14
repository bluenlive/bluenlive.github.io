---
layout: single
title: "libpng/zlib-ng를 cmake로 컴파일 할 때 유의사항"
date: 2025-11-14 11:45:00 +0900
categories:
  - ITTalk
---

최근에 [libpng](https://github.com/pnggroup/libpng){:target="_blank"}는 1.8.0 beta 단계로 들어왔고, [zlib-ng](https://github.com/zlib-ng/zlib-ng/commits/develop/){:target="_blank"}는 2.3.0 RC1 단계로 들어왔다.\
릴리즈 빌드가 나온 다음에 적용하는 것이 통상적이지만, 두 프로젝트 모두 이 정도면 적용할 수 있다고 보고 적용하기로 했다.

그런데, 솔루션 파일을 VS2022에서 컴파일해보니 뭔가 잘 되지 않는다...

```text
1>png.c
1>arm_init.c
1>C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.44.35207\include\arm_neon.h(21,1): error C1189: #error:  This header is specific to ARM targets
1>(소스 파일 '../../../arm/arm_init.c'을(를) 컴파일하는 중)
1>filter_neon_intrinsics.c
1>D:\_develop\VS2022\Projects\_libs_img\_ImageFormats_\PNG\libPNG\_source\lpng1800-251107-1800git__\arm\filter_neon_intrinsics.c(37,42): error C2143: 구문 오류: ')'이(가) '*' 앞에 없습니다.
1>D:\_develop\VS2022\Projects\_libs_img\_ImageFormats_\PNG\libPNG\_source\lpng1800-251107-1800git__\arm\filter_neon_intrinsics.c(37,42): error C2143: 구문 오류: '{'이(가) '*' 앞에 없습니다.
1>D:\_develop\VS2022\Projects\_libs_img\_ImageFormats_\PNG\libPNG\_source\lpng1800-251107-1800git__\arm\filter_neon_intrinsics.c(37,62): error C2143: 구문 오류: ';'이(가) '*' 앞에 없습니다.
1>D:\_develop\VS2022\Projects\_libs_img\_ImageFormats_\PNG\libPNG\_source\lpng1800-251107-1800git__\arm\filter_neon_intrinsics.c(38,5): warning C4228: 비표준 확장이 사용됨: 선언자 목록에서 쉼표 뒤의 한정자가 무시됩니다.
1>D:\_develop\VS2022\Projects\_libs_img\_ImageFormats_\PNG\libPNG\_source\lpng1800-251107-1800git__\arm\filter_neon_intrinsics.c(38,20): error C2143: 구문 오류: ';'이(가) '*' 앞에 없습니다.
```

손을 좀 대다가 그냥 이번 기회에 cmake로 빌드하는 쪽으로 넘어가기로 했다.

## zlib-ng

두 프로젝트 중 먼저 빌드해야 하는 쪽은 당연히 zlib-ng이다.\
가급적 static library로 프로젝트를 구성하려 한다.

`SRC_DIR`과 `LIB_DIR`을 적절히 설정하고 아래의 명령을 실행하면 된다.

```bash
cmake -S %SRC_DIR% -B "%~dp0x64" -G "Visual Studio 17 2022" -A x64 ^
  -DZLIBNG_ENABLE_TESTS=OFF ^
  -DZLIB_COMPAT=ON ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
  -DCMAKE_C_FLAGS="/arch:AVX2"
cmake --build "%~dp0x64" --config Release --target zlib-ng --parallel
```

여기서 유의해야 할 부분은 `DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded`이다.\
`DBUILD_SHARED_LIBS=OFF`를 지정해뒀지만, 이 부분이 누락되면 `/MD (MultiThreadedDLL)`로 컴파일되기 때문.

## libpng

libpng 역시 필요한 변수를 적절히 설정하고 아래를 실행하면 된다.

```bash
cmake -S %LIBPNG_SRC% -B %BUILD_X64% -G "Visual Studio 17 2022" -A x64 ^
  -DPNG_SHARED=OFF -DPNG_TESTS=OFF ^
  -DZLIB_INCLUDE_DIR=%ZLIB_SRC%\_build_\lib\release\x64 ^
  -DZLIB_LIBRARY=%ZLIB_SRC%\_build_\lib\release\x64\zlibstatic.lib ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
  -DCMAKE_C_FLAGS="/arch:AVX2" ^
  -Wno-dev
cmake --build %BUILD_X64% --config Release
```

여기도 zlib-ng와 마찬가지로 `DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded`를 설정해야 한다.

## 참고사항

- static library로 빌드하려면 `*SHARD=OFF` 외에 `DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded`도 추가할 것
  - 이 부분이 누락되면 CRT가 통일되지 않고, 빌드 옵션을 손 대야 함
- libpng가 내부적으로 사용하는 헤더도 함께 복사해야 함
  - pngdebug.h, pnginfo.h, pngpriv.h, pngstruct.h, pngtarget.h
- libpng에서는 각 아키텍처 별 SIMD 여부를 확인하기 위한 `check.h`도 함께 복사해야 함
- lib 파일이 /MD인지 /MT인지 확인하려면 VS 명령행에서 `dumpbin`을 사용할 것\
결과에서 `LIBCMT`가 나오면 `/MT`, `MSVCRT`가 나오면 `/MD` 빌드임

```bash
dumpbin /directives mozjpeg-static.lib | findstr DEFAULTLIB
```
