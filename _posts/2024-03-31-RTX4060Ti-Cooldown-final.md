---
layout: single
#classes: wide
title: "RTX 4060 Ti 시스템 온도와의 싸움 최종전"
categories:
  - ITTalk
---

[이전 글 1](/ittalk/RTX4060Ti-Undervolting/){:target="_blank"}, [이전 글 2](/ittalk/RTX4060Ti-Cooldown/){:target="_blank"}를 통해 시스템을 안정시켰다.  
하지만, [Topaz Video AI](https://www.topazlabs.com/topaz-video-ai){:target="_blank"}를 쓰다보니, 이러고 나서도 또 컴퓨터가 **또 다운**되는 경우가 생겼다.

## CPU spec

이렇게 된 김에 본질적인 시스템 스펙부터 한번 확인해보기로 했다.

내 CPU는 **AMD Ryzen 5900X** 이다.  
AMD 홈페이지에 명시된 [Ryzen 5900X의 스펙](https://www.amd.com/en/products/cpu/amd-ryzen-9-5900x){:target="_blank"}은 아래와 같다.

![image](</images/2024-03-31a/ryzen5900xs64_Q.png>){: .align-center}
*Up to 3200MT/s에 주목*

여기서 봐야 할 것은 메모리 속도를 최대 **3200MT/s까지 지원**한다는 것이다.  
그리고, 내 메모리는 TeamGroup DDR4 3600MHz이다.  
이를 XMP 프로파일을 적용하여 3600MT/s로 사용하고 있었다.

![image](</images/2024-03-31a/ram-teamgroup-ddr4-3600_B_Q.png>){: .align-center}

DDR4 3600MHz의 전송률은 3600MT/s로, 5900X에서 지원하는 3200MT/s보다 높은 속도이다.  
참고로, 이 두 값이 동일하다는 것은 [위키피디아](https://www.amd.com/en/products/cpu/amd-ryzen-9-5900x){:target="_blank"}에서 간단히 확인할 수 있다.

![image](</images/2024-03-31a/ddr4s64_Q.png>){: .align-center}

XMP 설정을 해제하고 **메모리 속도**를 **3200MT/s**로 **제한**하기로 했다.

![image](</images/2024-03-31a/20240325_144246600_iOSs64.jpg>){: .align-center}

## BIOS에서 언더볼팅

지금까지는 [**Ryzen Master**](https://www.amd.com/en/technologies/ryzen-master){:target="_blank"}를 통해 언더볼팅을 했다.  
이왕 이렇게 BIOS를 손댄 김에, BIOS에서 언더볼팅을 하기로 했다.

Curve Optimizer를 통해 **-25**로 설정했다.

![image](</images/2024-03-31a/20240325_144354075_iOSs64.jpg>){: .align-center}

전력 설정값은 이전과 동일하게 **PPT**는 **110 W**, **TDC**는 **95 A**, **EDC**는 **140 A**로 설정했다.

![image](</images/2024-03-31a/20240326_145733322_iOSs64.jpg>){: .align-center}

## 결과

극악의 환경을 돌려도 안 뻗는다.  
이제 정말 안정화된 것 같다.

![image](</images/2024-03-31a/cpuinfos64_Q.png>){: .align-center}
