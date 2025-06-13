---
layout: single
#classes: wide
title: "RTX 4060 Ti 시스템 온도와의 싸움 2차전"
categories:
  - ITTalk
---

[이전 글](/ittalk/RTX4060Ti-Undervolting/){:target="_blank"}에서 언더볼팅을 통한 시스템 안정성을 얘기했었다.  
그런데, [Topaz Video AI](https://www.topazlabs.com/topaz-video-ai){:target="_blank"}를 쓰다보니, 언더볼팅을 하고 나서도 컴퓨터가 **또 다운**되는 경우가 생겼다.

해외 포럼을 찾아보니 다행히(?) 나만의 문제는 아니고, 다양한 원인과 해결책들이 제시되었다.  
제작사에선 알기는 알면서도 왠지 미온적으로 대응하는 느낌이었고...

일단 다시 한 번 시스템을 쳐다보기로 했다.

당연한 얘기지만, 이 프로그램은 **전력 사용량**이 **매우 높음**으로 나온다.

![image](</images/2024-02-28/processess64_Q.png>){: .align-center}

그리고, **CPU**와 **GPU**를 골고루(?) 사용한다.  
우선 CPU 점유율은 아래와 같다. GPU와 함께 사용함에도 점유율이 상당히 높다.

![image](</images/2024-02-28/task_cpus64_Q.png>){: .align-center}

그런데, GPU 점유율은 생각보다 높지 않다.  
그렇다면, [이전 글](/ittalk/RTX4060Ti-Undervolting/){:target="_blank"}에서 짚은 내용이 충분하지 않다는 뜻이다.

![image](</images/2024-02-28/task_gpus64_Q.png>){: .align-center}

일단, [**MSI Afterburner**](https://www.msi.com/page/Afterburner){:target="_blank"}의 설정을 다시 한 번 확인했다.  
특이한 내용은 없다.

![image](</images/2024-02-28/msi_gpu_curve_Q.png>){: .align-center}

이것만으론 부족하니 [**Ryzen Master**](https://www.amd.com/en/technologies/ryzen-master){:target="_blank"}를 통해 CPU의 최대 전력 사용량도 줄여보기로 했다.  
**PPT**는 **110 W**, **TDC**는 **95 A**, **EDC**는 **140 A**로 설정했다.

![image](</images/2024-02-28/ryzen_masters64_Q.png>){: .align-center}

그리고, **Windows 10**의 **전원 옵션**에서 **최대 프로세서 상태**를 99%로 설정했다.

![image](</images/2024-02-28/cpusetting_B_Q.png>){: .align-center}

마지막으로, 본체 커버를 분리해버렸다.  

이렇게 하니 일단은 과부하로 다운되는 일은 없어졌다.  
하지만, 지난 포스팅의 맺음말도 비슷했[...]
