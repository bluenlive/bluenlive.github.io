---
layout: single
#classes: wide
title: "AMD CPU의 안전한 메모리 속도는?"
categories:
  - ITTalk
---

인텔이든 AMD든 어떤 CPU를 사용하든 사용할 수 있는 메모리의 속도는 제한이 있다.  
CPU 제조사인 AMD와 메인보드 제조사에서는 **이를 명시하고 있지만**, **많은 사람들이 이를 간과**하고 있다.

그리고, 평소에는 별 문제가 벌어지지도 않는다.

## CPU spec

내 CPU는 **AMD Ryzen 5900X** 이다.  
AMD 홈페이지에 명시된 [Ryzen 5900X의 스펙](https://www.amd.com/en/products/cpu/amd-ryzen-9-5900x){:target="_blank"}은 아래와 같다.

![image](/images/2024-05-01a/ryzen5900xs64_Q.png){: .align-center}
*Up to 3200MT/s에 주목*

여기서 봐야 할 것은 스펙 상으로는 메모리 속도를 최대 **3200MT/s (DDR4 3200)까지 지원**한다는 것이다.  

## Mainboard QVL

메인보드 제조사는 **메모리 속도**를 **제한**하는 **QVL**을 제공한다.  
**QVL**은 **Qualified Vendor List**의 약자로, **메인보드 제조사가 테스트한 메모리**의 **목록**이다.

아래 목록은 [ASRock의 B550M Steel Legend의 메모리 QVL](https://www.asrock.com/mb/AMD/B550M%20Steel%20Legend/index.asp#MemoryVM){:target="_blank"}이다.

![image](/images/2024-05-01a/memory_with_MB_Bs64_Q.png){: .align-center}

내가 사용하는 메모리는 **TeamGroup DDR4 3600 32GB(Hynix)**이다.  
목록에는 같은 라인업의 메모리가 있는데, **32GB**가 아니라 **16GB**까지만 있다.

## 3600으로 설정

이 정도 상황이면 일단 3600으로 설정해도 된다고 생각했다.  
그래서, 바이오스에서 XMP 프로파일을 적용하여 3600MT/s로 사용하고 있었다.

![image](/images/2024-05-01a/20240325_144246600_iOSs64.jpg){: .align-center}

그리고, 평소에는 아무 문제가 없었다.  
**평소에는**...

하지만, 문제는 [Topaz Video AI](https://www.topazlabs.com/topaz-video-ai){:target="_blank"} 등을 사용하는 경우에 발생했다.

관련 포럼들을 뒤져보면 의외로 이 프로그램이 갑자기 컴퓨터를 다운시키는 경우가 많았다.  
물론, 자신이 해결했던 방법을 공유하는 글도 많았고...

어쨌거나, 매년 돈을 꼬박꼬박 내며 사용하는 프로그램인데, 이걸 쓰다가 컴퓨터가 다운되다니...

## 원론으로 돌아가 3200으로 제한

이전 글들에서도 얘기했듯이 이 문제를 해결하기 위해 다양한 시도들을 했었다.  
CPU의 전력을 줄이고, GPU 사용량도 줄이고 등등...

그런데, 그 중 중요한 지점 하나가 **메모리 속도**였다.

근본적으로 다시 생각해보면 내 시스템에서 3600이 동작할 것이라는 건 **가정**에 불과했다.  
CPU에선 **3200을 명시**했고, 메인보드 제조사 쪽 목록엔 **3600을 지원하는 동일한 제품은 없었다**.

그리고, **3200으로 제한**한 이후엔 다운되는 현상이 없어졌다.

## 이 현상은 ZEN3 CPU에서만?

종종 AMD ZEN4 CPU에서도 비슷한 현상에 대한 유튜브 영상을 볼 수 있다.  
즉, 최신 AMD CPU에서 고성능 DDR5 메모리를 사용하면 안정성 문제가 발생할 수 있다는 것이다.

그런데, AMD 홈페이지에는 [ZEN4 CPU에서는 DDR5-5200까지 지원](https://www.amd.com/en/products/processors/desktops/ryzen/7000-series/amd-ryzen-9-7950x3d.html){:target="_blank"}한다고 명시되어 있다.

![image](/images/2024-05-01a/DDR5_B_Q.png){: .align-center}
*ZEN4 CPU에서는 DDR5-5200이 최대 속도*

ZEN4 시스템을 갖고 있지 않아서 직접 확인해볼 순 없지만, **메모리 속도**는 반드시 확인해봐야 할 것이다.  
그리고, 안정성을 위해서는 가급적 **CPU에 명시**된 **최대 메모리 속도**를 따르는 것이 좋을 것이라 생각한다.
