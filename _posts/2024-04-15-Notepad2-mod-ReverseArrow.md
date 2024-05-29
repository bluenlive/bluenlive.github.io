---
layout: single
title: "Notepad2-mod 마우스 커서 뒤집기 삽질기"
categories:
  - Notepad4
---

Notepad2-mod에서는 특정 영역에 마우스 커서를 올리면 좌우가 바뀐 화살표가 표시된다.  
그런데, HiDPI 환경이나 마우스 커서의 크기를 조절한 경우에도 **원래의 크기로만 표시**되는 문제가 있었다.

## 마우스 커서의 크기 문제

이 문제는 비단 Notepad2-mod만이 아니라 Scintilla 기반의 에디터들이 공통적으로 가지고 있는 문제다.  
이 문제에 대해서는 [일찌기 Scintilla의 버그로 등록](https://sourceforge.net/p/scintilla/bugs/2321/){:target="_blank"}되어 있지만, 아직 해결되지 않은 상태였다.

이 문제의 근본적인 원인은 현재 마우스 커서의 크기를 제대로 리턴해주는 API가 없기 때문이다.

```cpp
const int width = SystemMetricsForDpi(SM_CXCURSOR, dpi);
const int height = SystemMetricsForDpi(SM_CYCURSOR, dpi);
```

이런 거 아무리 열심히 호출해봤자 `SM_CXCURSOR`와 `SM_CYCURSOR`는 항상 `32`로 리턴된다.

Notepad2-mod 쪽에서도 [이 문제를 알고 있고](https://github.com/zufuliu/notepad2/issues/635){:target="_blank"}, 토의도 있었지만 답이 없었다.

## 외부 커서 파일 사용 시도

그런데, 이번에 이 문제를 다른 방향에서 접근해보기로 했다.  
[별도의 마우스 커서 파일을 만들어서 사용](https://github.com/zufuliu/notepad2/discussions/784){:target="_blank"}하는 것이다.

그런데, 막상 마우스 커서 파일을 만들려고 하니, 괜찮은 커서 제작 툴이 없었다.  
필요한 프로그램은 파일 하나에 커서 여러 개를 넣어주는 프로그램인데, 이런 프로그램을 못 찾은 것이다.  
그럼 뭐 그것부터 직접 만들어야지...

윈도우의 마우스 커서는 아이콘과 동일한 포맷을 사용한다.  
`ICONDIR`에서 `image type`만 다르게 기술하고, `hotspot`만 지정해주면 되는 것이다.  
아이콘과 동일하게 `BMP` 포맷 외에 `PNG` 포맷도 적용할 수 있다.

**그런데!!!**  
이렇게 만들어 컴파일을 해보니 **링킹 에러**가 발생했다.

```plaintext
Error RC2176: old DIB in ReverseArrow.cur; pass it through SDKPAINT
```

놀랍게도 원인은 **PNG 포맷의 커서 파일을 링킹할 수 없다**는 것이다...  
물론, 그냥 BMP 포맷으로 바꾸면 되겠지만, 파일 크기가 커지니 그건 좀 아닌 것 같고...

그래서 일단 BMP 포맷의 커서를 링킹한 뒤, 이를 [Resource Hacker](https://www.angusj.com/resourcehacker/){:target="_blank"}로 PNG 커서로 교체했다.

![image](</images/2024-04-15/notepad2_B_Q.png>){: .align-center}
*왼쪽에 정상적으로 표시되는 찬란한 커서*

## API와 레지스트리를 이용한 해결책

Scintilla/Notepad2-mod 본진에서는 이와는 다른 방향으로 진행하고 있다.  
[커서 크기를 레지스트리에서 읽어](https://learn.microsoft.com/en-us/answers/questions/815036/windows-cursor-size){:target="_blank"} 처리하는 것이다.

이 방향이 **코드 자체로는 좀 더 깔끔**하기는 한데, 마우스 커서가 좀 **예쁘지 않다**는 단점이 있다.  
32x32의 커서를 그대로 키워서 표시하기 때문이다.

본 블로그에서 배포하는 버전은 **외부 커서 파일을 사용**하는 방향으로 진행하기로 했다.
