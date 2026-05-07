---
layout: single
title: "Notepad4에 적용된 천재적인 수식 계산 아이디어"
date: 2026-5-7 10:59:00 +0900
categories:
  - Notepad4
---

## 메모장에도 수식 계산 기능이 있으면 좋잖아?

정확히 3년 전에 [Notepad2-mod에 수식 기능을 추가하는 아이디어](https://github.com/zufuliu/notepad4/discussions/631)를 건의했었다.

필요하다는 얘기도 있었지만, 이 기능을 구현하면 **실행파일의 크기가 너무 커진다**는 문제가 있었다.\
본 블로그에서 배포하는 버전은 화끈하게 [tinyexpr-plusplus](https://github.com/Blake-Madden/tinyexpr-plusplus)를 적용했었다.\
그것으로 인해 실행파일은 **약 200KiB** 더 커졌다.

## Chakra

최근에 [Matteo-Nigro](https://github.com/Matteo-Nigro)라는 귀인께서 천재적인 아이디어로 이를 구현하셨다.

윈도우에는 **Chakra**라는 **JScript 엔진**이 내장되어 있다.\
지금은 Edge가 **Chromium Edge**로 전환되면서 사실상 **명예로운 퇴진**을 한 상태이지만...

하지만, 이 엔진은 여전히 윈도우에 내장되어 있고, 굳이 MS가 이를 제거할 것으로 보이지도 않는다.\
이미 많은 프로젝트에서 사용하기 때문에 제거하는 게 오히려 부담이 클 것이다.

## Chakra 적용 코드는?

귀인께서는 메모장4 소스 중에 `Brigde.cpp`에 이 기능을 구현하셨다.

이 코드는 몇 가지 기발한 아이디어들이 적용되어 있다.

{: .bluebox-blue}
* 직접 수식 해석을 구현하지 않고 Chakra를 활용
* 결과를 다시 문자열로 변환할 때는 `propsys.dll`의 `VariantToString`을 활용
* **수식 계산**과 **JS의 표현식 평가**를 함수 하나로 처리
  * JS의 표현식을 평가할 때 수식을 사용하려면 `Math.`를 사용하고
  * 수식 계산 기능은 `with(Math)`를 내부적으로 붙이는 방식으로 구현
  * 그 결과로 종종 제곱으로 많이 사용되는 `^`는 JS 특성상 `XOR`로 동작

```cpp
static const GUID CLSID_Chakra = // {1b7cd997-e5ff-4932-a7a6-2a9e636da385}

void EditCalculateExpr(int menu) {
  Sci_Position iSelCount = SciCall_GetSelTextLength();

    // (생략)

  using VariantToStringSig = HRESULT (WINAPI *)(REFVARIANT varIn, PWSTR pszBuf, UINT cchBuf);
  HMODULE hDLL = LoadLibraryExW(L"propsys.dll", nullptr, kSystemLibraryLoadFlags);
  static VariantToStringSig pfnVariantToString = DLLFunction<VariantToStringSig>(hDLL, "VariantToString");

    // (생략 및 일부 간략화)

  IActiveScript *activeScript = nullptr;
  HRESULT hr = CoCreateInstance(CLSID_Chakra, nullptr, CLSCTX_INPROC_SERVER, IID_IActiveScript, AsPPVArgs(&activeScript));
  if (!SUCCEEDED(hr)) {
    CLSID clsidScript;
    hr = CLSIDFromProgID(L"JavaScript", &clsidScript);
    if (SUCCEEDED(hr)) {
      hr = CoCreateInstance(clsidScript, nullptr, CLSCTX_INPROC_SERVER, IID_IActiveScript, AsPPVArgs(&activeScript));
    }
    if (!SUCCEEDED(hr)) {
      return;
    }
  }

  constexpr size_t padding = 1024; // for CMD_CALCULATE_EXPR
  iSelCount = NP2_align_up(iSelCount + 1, MEMORY_ALLOCATION_ALIGNMENT);
  iSelCount = max<Sci_Position>(iSelCount, 1024); // increased to store result and error message
  CalcContext context;
  context.textLength = (iSelCount * (sizeof(char) + sizeof(WCHAR)*2)) + (padding * sizeof(WCHAR));
  context.lineStart = 0;
  context.pszText = static_cast<char *>(NP2HeapAlloc(context.textLength));
  context.cpEdit = SciCall_GetCodePage();

  hr = activeScript->SetScriptSite(&context);
  if (SUCCEEDED(hr)) {
    IActiveScriptParse* scriptParse = nullptr;
    hr = activeScript->QueryInterface(IID_IActiveScriptParse, AsPPVArgs(&scriptParse));
    if (SUCCEEDED(hr)) {
      hr = scriptParse->InitNew();
      if (SUCCEEDED(hr)) {
        VARIANT result;
        VariantInit(&result);
        char * const pszText = context.pszText;
        WCHAR * const pszTextW = reinterpret_cast<LPWSTR>(pszText + iSelCount);
        SciCall_GetSelText(pszText);
        MultiByteToWideChar(context.cpEdit, 0, pszText, -1, pszTextW, static_cast<int>(iSelCount));
        LPWSTR pszBuf = pszTextW;
        if (menu == CMD_CALCULATE_EXPR) {
          context.lineStart = 1;
          pszBuf += iSelCount;
          wsprintf(pszBuf, L"with(Math){eval(\n%s)}", pszTextW);
        }
        hr = scriptParse->ParseScriptText(pszBuf, nullptr, nullptr, nullptr, 0, 0, SCRIPTTEXT_ISEXPRESSION, &result, nullptr);
        if (SUCCEEDED(hr)) {
          pszTextW[0] = L'\0';
          iSelCount = iSelCount*2 + padding;
          hr = pfnVariantToString(result, pszTextW, static_cast<UINT>(iSelCount));
          if (SUCCEEDED(hr) && pszTextW[0]) {
            pszText[0] = ' ';
            iSelCount = context.textLength - 1;
            iSelCount = WideCharToMultiByte(context.cpEdit, 0, pszTextW, -1, pszText + 1, static_cast<int>(iSelCount), nullptr, nullptr);
            const Sci_Position iSelEnd = SciCall_GetSelectionEnd();
            SciCall_InsertText(iSelEnd, pszText);
            SciCall_SetSel(iSelEnd, iSelEnd + iSelCount);
          }
        }
        VariantClear(&result);
      }
      scriptParse->Release();
    }
  }

  activeScript->Close();
  activeScript->Release();
  NP2HeapFree(context.pszText);
}
```

## 내 메모장4에서의 구현은?

기존 버전에서는 전술했듯이, [tinyexpr-plusplus](https://github.com/Blake-Madden/tinyexpr-plusplus)를 활용하여 구현했었다.\
단축키는 `Ctrl+Enter`로 지정해서 수식 뒤에서 `Ctrl+Enter`를 누르면 결과를 붙이도록 했다.

이제 이 기능을 제거하고 순정품의 수식 계산 기능만 적용할 예정.

![image](/images/2026-05-07/notepad4_B_Q.webp)
*식 계산 메뉴는 도구-선택영역에 대하여 에 위치함*

이에 따라 `Excel`의 일부 식에 대한 구현도 제거되고, `cbrt()`[^1] 함수도 제거.

[^1]: C 기본 라이브러리에 포함된 세제곱근 함수
