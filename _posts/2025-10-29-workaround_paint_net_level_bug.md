---
layout: single
title: "Paint.NET levels 필터 오류 우회법"
date: 2025-10-29 23:18:00 +0900
categories:
  - ITTalk
---

[Paint.NET](https://getpaint.net/){:target="_blank"}은 굉장한 기능을 제공하는 무료 이미지 편집 도구이다.\
기본 기능도 훌륭함은 물론, 사용자가 직접 필터를 만들어 적용할 수 있는 환경도 제공한다.

그런데, 언제부터인가 levels(수준) 기능을 적용하면 오동작을 보이기 시작했다.

![image](</images/2025-10-29/buggy_yes_okl_s64_Q.png>){: .align-center}

위 화면처럼 한쪽 그래프만 표시되지 않을 때도 있고, 때로는 좌우의 그래프가 모두 안 보이는 경우도 있다.\
또한, 이 오류가 발생하고 나면 **프로그램 자체가 다운**되는 경우도 발생한다.

[본진 포럼](https://forums.getpaint.net/topic/134088-paintnet-issues-with-levels/){:target="_blank"}을 보니 나만 겪는 문제는 아닌 것 같다.\
그리고, 아직까지 원인이나 이 오류가 발생하는 상황도 잘 정리가 안 된 것 같다.

일단 이 오류를 우회하는 방법은 의외로 간단(?)하다.\
설정에서 **하드웨어 가속 기능을 끄면** 된다.

![image](</images/2025-10-29/config_B_okl_s64_Q.png>){: .align-center}

이러면 아래와 같이 levels 기능이 정상적으로 동작하는 것을 볼 수 있다.

![image](</images/2025-10-29/buggy_no_okl_s64_Q.png>){: .align-center}

---

그런데, 문제는 이 오류가 어떤 상황에서 발생하는지도 정리가 된 것 같지 않다는 것이다.\
포럼의 글을 읽다보면 시스템에 GPU가 2개 잡히는 경우에 그렇다는 경험담도 있는데, 다음 환경들에서 테스트 한 결과 그 문제는 아닌 것 같았다.

1. UEFI에서 CPU(Ryzen 9700X) **내장 GPU를 활성화**하고 **외장 GPU(RTX 4070S)를 장착**한 환경에서 **오류 발생**
2. UEFI에서는 CPU의 iGPU를 활성화하고, **장치 관리자**에서 **iGPU를 비활성화**한 뒤 **GPU를 장착**한 환경에서 **오류 발생**
3. **UEFI에서 CPU의 iGPU를 비활성화**하고 **외장 GPU만 사용**한 환경에서 **오류 발생**

이거 진짜 원인은 대체 뭐란 말이냐...
