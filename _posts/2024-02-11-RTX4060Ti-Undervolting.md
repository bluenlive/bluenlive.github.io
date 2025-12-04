---
layout: single
#classes: wide
title: "RTX 4060 Ti 언더볼팅"
categories:
  - ITTalk
---

게임을 하지 않는 나로서는 언더볼팅을 통해 그래픽카드의 성능을 끌어낼 큰 이유가 없었다.  
그런데, [Topaz Video AI](https://www.topazlabs.com/topaz-video-ai){:target="_blank"}나 [stablediffusion](https://github.com/Stability-AI/stablediffusion){:target="_blank"} 등을 사용하면서 상황이 조금 바뀌었다.  
GPU를 많이 사용하게 되니, 가끔씩 컴퓨터가 다운되는 경우가 생긴 것이다.  
그리고 원인과 해결책을 찾다보니 **그래픽 카드의 과부하**가 원인이었다.

RTX 4060 Ti는 [MSI Afterburner](https://www.msi.com/page/Afterburner){:target="_blank"}로 손쉽게 언더볼팅을 할 수 있다.
상세한 방법은 아래 영상을 참조.

{% include video id="1tPXy3SCpDE" provider="youtube" %}

프로그램 실행 화면은 아래와 같고...

![image](/images/2024-02-11/msi1_B_Q.png){: .align-center}

**Curve Editor**를 통해 조정한 값은 아래와 같다.

![image](/images/2024-02-11/msi2_B_Q.png){: .align-center}

이렇게 하니 AI 모델을 돌리는 도중에도 컴퓨터가 다운되는 일이 없어졌다. 만세!
