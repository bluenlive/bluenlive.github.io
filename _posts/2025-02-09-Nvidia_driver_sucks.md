---
layout: single
title: "엉망진창 Nvidia 드라이버"
date: 2025-2-9 16:55:00 +0900
categories:
  - ITTalk
---

올해 출시될 그래픽 카드 중 뭘 구매할지 고민을 하고 있었다.\
그러다가 예상보다 더 지저분한 상황이 예상되어 깔끔하게 포기하고 **RTX 4070s**를 구매했다.

제조사를 인텔이나 AMD로 바꾸지 않은 것은, [MainConcept의 HEVC 인코더](https://www.mainconcept.com/ffmpeg){:target="_blank"}와 궁합도 한몫 했다.\
그리고, 다른 제조사들에 비해 높은 드라이버 안정성도 역시 한몫 했다.\
그러나...

![image](</images/2025-02-09b/nvidiadriver_Bs64_Q.png>){: .align-center}
*문제 덩어리 572.16 드라이버*

최근에 메인보드 바이오스도 업데이트 되는 김에, 메인보드 바이오스, 드라이버 및 글카 드라이버를 업데이트 했다.\
그런데, 오히려 안정성이 떨어지는 현상이 발생했다.\
화면 절전 모드에 다녀오면 **RTX 4070s가 화면을 인식하지 못하는 현상**이 발생한 것다

하필 이 업데이트들을 한방에 하는 바람에 원인을 찾는데 시간이 걸렸다.\
하나씩 롤백과 업데이트를 섞어서 해보니 원인을 찾을 수 있었다.\
메인보드 쪽은 문제가 없었고, **Nvidia 최신 드라이버**의 문제였다.

바로 이전 버전을 포함한 어떤 버전으로 롤백해도 아무런 문제가 발생하지 않았다.\
그래서, **572.16 드라이버**를 삭제하고 **566.36 드라이버**를 설치했다.

![image](</images/2025-02-09b/nvidia_old_Bs64_Q.png>){: .align-center}
*사랑과 우정의 상징 566.36 드라이버*

좀 더 뒤져보니, 이게 나만의 문제가 아니라 세계적으로 벌어지는 이슈였다.

1. 572.16 드라이버는 **RTX 50xx 시리즈**를 대상으로 나온 드라이버이나 거기서는 **화면 인식 문제** 발생
2. 572.16 드라이버는 **RTX 40xx 시리즈**에서도 **화면 인식 문제** 발생

<div class="quoteMachine">
  <div class="theQuote">
    <blockquote><span class="quotationMark quotationMark--left"></span >
황 회장... 너 이럴래?
    <span class="quotationMark quotationMark--right"></span ></blockquote>
  </div>
</div>
