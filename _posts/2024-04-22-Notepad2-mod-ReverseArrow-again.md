---
layout: single
title: "Notepad2-mod 마우스 커서 뒤집기 삽질기 #2"
categories:
  - Notepad4
---

[이전 글](/notepad4/Notepad2-mod-ReverseArrow/){:target="_blank"}에서 다뤘던 마우스 커서 뒤집기가 수정되어 간단히 포스팅.

## 개요

이전에 본 블로그에서 배포하는 버전은 **외부 커서 파일을 사용**하는 방향으로 진행하기로 했었다.  
윈도우 API에서 직접 읽었을 때 커서가 **예쁘지 않다**는 단점이 있었기 때문이었다.

그런데, 이번에 Notepad2-mod의 본진에서 이 문제를 해결했다.  
이에 따라 본 블로그에서 배포하는 버전도 본진을 따라 **별도 커서 리소스 대신 UI에서 읽어서 처리**하도록 수정했다.

## 기존의 해결책 (요약)

마우스 커서를 뒤집어 출력하는 것이 쉽지 않아 [별도의 마우스 커서 파일을 만들어서 적용](https://github.com/zufuliu/notepad2/discussions/784){:target="_blank"}했었다.

이 과정에서 **마우스 커서 파일을 만들어주는 프로그램을 간단히 만들어** 적용했다.  
그런데, **PNG 포맷의 커서 파일을 링킹할 수 없다**는 문제가 발생해 이를 또 우회했다.

![image](</images/2024-04-22/notepad2_B_Q.png>){: .align-center}
*왼쪽에 정상적으로 표시되는 찬란한 커서*

## API와 레지스트리를 이용한 해결책

Scintilla/Notepad2-mod 본진에서는 이와는 다른 방향으로 진행하고 있었다.  
[커서 크기를 레지스트리에서 읽어](https://learn.microsoft.com/en-us/answers/questions/815036/windows-cursor-size){:target="_blank"} 처리하는 것이다.

애초에 Scintilla가 플랫폼 독립적인 라이브러리이기 때문에, 이런 방향으로 진행하는 것이 맞다.  
그리고, 이 방향이 **코드 자체로도 좀 더 깔끔**하기도 하다.  
하지만, 마우스 커서가 좀 **예쁘지 않다**는 단점이 있었다.

그런데, 결국 [방법을 찾아내고야 말았다](https://github.com/zufuliu/notepad2/commit/185311d3ac339f473ee7a8eb8dfe8d0e301b7f35){:target="_blank"}.  
간단히 요약하면 **레지스트리에서 커서 파일의 정보까지 읽어서** 처리하는 것이다.

![image](</images/2024-04-22/notepad2_again_B_Q.png>){: .align-center}
*그래, 순정 커서가 예쁘게 나와야지*
