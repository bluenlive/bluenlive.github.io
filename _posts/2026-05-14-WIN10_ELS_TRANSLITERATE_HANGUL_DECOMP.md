---
layout: single
title: "윈도우 10에 내장된 한글 자소 분리 API에 대한 고찰"
date: 2026-05-14 19:53:00 +0900
categories:
  - algorithm
---

## 1. 개요

한글을 다루는 소프트웨어에서 완성형 글자를 초/중/종성으로 분리해야 할 일이 종종 있다.\
보통은 유니코드의 완성형 한글 공식(`0xAC00`)을 이용해 산술적으로 구현한다.

놀랍게도 윈도우 10부터는 OS 내부에 이를 알아서 처리해 주는 ELS[^1] 기능이 조용히 추가되어 있었다.\
검색 엔진 인덱싱 등을 위해 만들어진 숨겨진 기능인 것 같다.

이 기능은 [Notepad4](https://github.com/zufuliu/notepad4)에도 구현되어 있다.

## 2. ELS로 한글 분리하기 (C++ 직접 호출)

이 기능은 `WIN10_ELS_GUID_TRANSLITERATION_HANGUL_DECOMPOSITION` 이라는 GUID를 호출하여 사용한다.\
COM 기반의 API를 사용하며, `<elscore.h>`를 통해 접근할 수 있다.

```cpp
#include <windows.h>
#include <elscore.h>
#include <string>

#pragma comment(lib, "elscore.lib")

// 윈도우 10 전용 한글 자소 분리 GUID
const GUID WIN10_ELS_GUID_TRANSLITERATION_HANGUL_DECOMPOSITION =
    { 0x4BA2A721, 0xE43D, 0x41b7, { 0xB3, 0x30, 0x53, 0x6A, 0xE1, 0xE4, 0x88, 0x63 } };

std::wstring DecomposeHangulELS(const std::wstring& input) {
    if (input.empty()) return L"";

    MAPPING_ENUM_OPTIONS enumOptions = { 0 };
    enumOptions.Size = sizeof(MAPPING_ENUM_OPTIONS);
    enumOptions.pGuid = const_cast<GUID*>(&WIN10_ELS_GUID_TRANSLITERATION_HANGUL_DECOMPOSITION);

    PMAPPING_SERVICE_INFO pServiceInfo = nullptr;
    DWORD serviceCount = 0;

    // OS에 ELS 서비스 요청 (Win 8.1 이하는 실패함에 유의)
    if (FAILED(MappingGetServices(&enumOptions, &pServiceInfo, &serviceCount)) || serviceCount == 0) {
        return input; 
    }

    MAPPING_PROPERTY_BAG bag = { 0 };
    bag.Size = sizeof(MAPPING_PROPERTY_BAG);

    // 변환 실행
    HRESULT hr = MappingDoAction(pServiceInfo, nullptr, input.c_str(), (DWORD)input.length(), nullptr, &bag);

    std::wstring result = input;
    if (SUCCEEDED(hr) && bag.prgResult != nullptr) {
        result = std::wstring(static_cast<LPCWSTR>(bag.prgResult), bag.dwResultLength / sizeof(WCHAR));
        MappingFreePropertyBag(&bag);
    }

    MappingFreeServices(pServiceInfo);
    return result;
}
```

## 3. ELS의 숨겨진 디테일: 'ㄳ'은 쪼개고 'ㄲ'은 놔둠

ELS의 처리 방식이 어떻게 동작하는지를 좀 더 깊이 분석해봤다.

ELS가 흥미로운 지점은 단순한 수학적(?) 분리가 아니라는 점이다.\
현대 **한국어의 입력 방식(타수)를 기준으로 처리**한다.

* **복합 자음/모음의 선택적 분리**
  * 첫가끝 코드로 분리하지 않고 한글 호환 자모(`0x3131` ~ `0x3163`)로 분리함
  * 일반적인 완성형은 물론 상식적으로 처리함
    * `책` --> `ㅊ, ㅐ, ㄱ`
  * `ㄳ`, `ㄼ` 같은 겹받침이나 `ㅘ`, `ㅞ` 같은 이중 모음은 `ㄱㅅ`, `ㄹㅂ`, `ㅗㅏ`, `ㅜㅔ` 로 분리함
    * `궭` --> `ㄱ, ㅜ, ㅔ, ㄹ, ㄱ`
  * `ㄲ`, `ㄸ` 이나 `ㅐ`, `ㅔ` 처럼 한 번에 입력되면 분리하지 않음
    * `똠` --> `ㄸ, ㅗ, ㅁ`

* **옛한글(고어)의 철저한 무시**
  * `ㅦ`, `ㅧ` 처럼 현대 표준에 없는 옛 자모 등 `U+3164`(채움 문자) 이후의 영역은 무시함
    * MS가 철저히 현대인의 실사용 검색에 초점을 맞췄다는 의미로 해석됨

## 4. 그런데 말입니다…

이렇게 똑똑하게 잘 설계됐지만, 어쨌거나 서비스 객체를 찾고 메모리를 할당/해제하는 COM API의 번거로움이 있다.\
게다가, **윈도우 8.1 이하에서는 동작하지 않는다**는 점도 있다.

현재 개발 중인 [Notepad++](https://notepad-plus-plus.org/) 용 플러그인에는 이 기능을 API를 사용하지 않고 직접 구현했다.\
코드가 그렇게 길지도 않은데다, Notepad++는 **윈도우 8.1**까지 공식적으로 지원하기 때문.

[^1]: ELS꞉ Extended Linguistic Services
