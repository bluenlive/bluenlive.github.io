---
layout: single
title: "Paint.NET levels 필터 오류 우회법 #2"
date: 2025-11-20 19:53:00 +0900
categories:
  - ITTalk
---

[이전 글](/ittalk/workaround_paint_net_level_bug/)보다 더 발전된(?) 오류 우회법을 발견하여 포스팅.

윈도우 설정에서 `시스템 > 디스플레이 > 그래픽`으로 이동하면 어플리케이션 별로 GPU 사용을 지정할 수 있다.

![image](</images/2025-11-20/workaround_B_okl_s64_Q.png>){: .align-center}

그 화면에서 Paint.NET에 대해서 기본 설정을 `AMD Radeon(TM) Graphics`으로 하면 Paint.NET이 프리징 되는 문제를 피할 수 있다.

Paint.NET에서 아래와 같이 HW 가속을 지정해도…

![image](</images/2025-11-20/ui_hw_B_okl_s64_B_Q.png>){: .align-center}

이렇게 정상적으로 표시되는 것을 볼 수 있다.

![image](</images/2025-11-20/level_ok_B_okl_s64_Q.png>){: .align-center}

덧. **윈도우 설정에서 NVIDIA를 지정하면 프리징** 됨
