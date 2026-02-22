---
layout: single
#classes: wide
title: "시놀로지 속도 이슈 #2꞉ 2.5Gbps라는 꿈"
date: 2026-2-22 09:44:00 +0900
categories:
  - ITTalk
series: "Synology_NAS_Speed_Issue"
series_title: "시놀로지 NAS 접속 속도 이슈"
---

## 3. 욕심: 1Gbps도 부족하다. 2.5Gbps로 가자ǃ

약 1년쯤 전에 [2.5Gbps 구축을 준비](/ittalk/Prepare_to_2.5Gbps/)하다 실패한 적이 있었다.\
시놀로지 NAS용 2.5Gbps 이더넷 USB 어댑터 드라이버가 오동작을 한 게 원인이었다.

그 어댑터는 다른 용도로 이미 사용해버렸는데, 정신을 차려보니 손에 또 하나가 있었다.

![image](/images/2026-02-22/USB2.5_okl_s64_Q.png){: .align-center}
*너는 이미 질러져 있다!*

이 어댑터는 **RTL8156B**를 기반으로 하는 2.5GbE USB 어댑터다.\
왜 이걸 또 샀냐면... [해당 드라이버가 업데이트](https://github.com/bb-qq/r8152){:target="_blank"} 되었기 때문.

그리고, 이번 업데이트는 [송신 큐의 timeout을 수정](https://github.com/bb-qq/r8152/commit/b6a96ccb711339852694b11fc49c8c65eb16f60c){:target="_blank"}했다고 하니 뭔가 될 것 같았다.\
설치해서 사용해보니, 장시간 사용에도 별다른 문제가 없었다.\
드디어 **드라이버의 문제가 해결**된 것 같았다.

## 4. 난관: 그래도 테스트는 제대로 해봐야지

네트워크 대역폭을 제대로 테스트 하고 싶으면 [iPerf](https://iperf.fr/iperf-download.php){:target="_blank"}를 사용하면 된다.\
NAS 쪽에서 서버 모드로 실행하고 윈도우 쪽에서 클라이언트 모드로 실행하면 간편하게 할 수 있다.

시놀로지 쪽에서 이를 설치하려면 `SynoCli Monitor Tools`를 설치하면 간단하게 활용 가능하다.

![image](/images/2026-02-22/packages_B_okl_s64_Q.png){: .align-center}

윈도우는 아래 명령으로 설치할 수 있다.

```bash
winget install iperf3
```

다음으로 NAS에 SSH로 접속해서 아래와 같은 명령으로 iPerf3을 서버 모드로 실행한다.

```bash
iperf3 -s
```

이제 윈도우 쪽에서 하나씩 테스트해보면 된다.\
일단 PC → NAS 송신 테스트를 5분간 해봤다.

```bash
iperf3 -c 172.∗∗.∗.∗∗∗ -t 300 -i 1
```

결과는 다음과 같았다.

```text
PS C:\Users\bluen> iperf3 -c 172.∗∗.∗.∗∗∗ -t 300 -i 1
Connecting to host 172.∗∗.∗.∗∗∗, port 5201
[  5] local 172.∗∗.∗.∗∗ port 11769 connected to 172.∗∗.∗.∗∗∗ port 5201
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.01   sec   118 MBytes   980 Mbits/sec
[  5]   1.01-2.01   sec   114 MBytes   949 Mbits/sec
[  5]   2.01-3.00   sec   112 MBytes   949 Mbits/sec
[  5]   3.00-4.01   sec   114 MBytes   950 Mbits/sec
[  5]   4.01-5.00   sec   112 MBytes   950 Mbits/sec
                        ⋮
[  5] 295.00-296.01 sec   114 MBytes   950 Mbits/sec
[  5] 296.01-297.01 sec   112 MBytes   949 Mbits/sec
[  5] 297.01-298.01 sec   114 MBytes   949 Mbits/sec
[  5] 298.01-299.01 sec   113 MBytes   950 Mbits/sec
[  5] 299.01-300.00 sec   113 MBytes   949 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-300.00 sec  33.1 GBytes   947 Mbits/sec                  sender
[  5]   0.00-300.03 sec  33.1 GBytes   946 Mbits/sec                  receiver

iperf Done.
PS C:\Users\bluen>
```

이 얼마나 아름다운 결과인가...!!\
드디어 **PC에서 NAS로 1Gbps**를 실제로 **송신할 수 있는** 것이다!!

다음으로 NAS → PC 송신 테스트를 해봤다.\
이 테스트만 완료되면 USB 어댑터로 1Gbps를 완벽하게 쓸 수 있고, 그럼 바로 **2.5Gbps로 넘어갈 준비**가 되는 것이다.

```bash
iperf3 -c 172.∗∗.∗.∗∗∗ -t 30 -R
```

그리고, 결과는...

```text
PS C:\Users\bluen> iperf3 -c 172.∗∗.∗.∗∗∗ -t 30 -R
Connecting to host 172.∗∗.∗.∗∗∗, port 5201
Reverse mode, remote host 172.∗∗.∗.∗∗∗ is sending
[  5] local 172.∗∗.∗.∗∗ port 9827 connected to 172.∗∗.∗.∗∗∗ port 5201
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.01   sec   113 MBytes   941 Mbits/sec
[  5]   1.01-2.01   sec  27.6 MBytes   230 Mbits/sec
[  5]   2.01-3.01   sec  0.00 Bytes  0.00 bits/sec
[  5]   3.01-4.01   sec  0.00 Bytes  0.00 bits/sec
[  5]   4.01-5.01   sec  0.00 Bytes  0.00 bits/sec
[  5]   5.01-6.00   sec  0.00 Bytes  0.00 bits/sec
[  5]   6.00-7.01   sec  0.00 Bytes  0.00 bits/sec
[  5]   7.01-8.01   sec  0.00 Bytes  0.00 bits/sec
[  5]   8.01-9.01   sec  0.00 Bytes  0.00 bits/sec
[  5]   9.01-10.01  sec  0.00 Bytes  0.00 bits/sec
[  5]  10.01-11.01  sec  0.00 Bytes  0.00 bits/sec
[  5]  11.01-12.00  sec  0.00 Bytes  0.00 bits/sec
```

그렇다...\
**NAS에서 PC**로 대량의 데이터를 보내는 건 **실패**한 것이다.

이후 NAS 측에서 `ethtool`로 다양한 튜닝을 해봤지만, 결론은 동일했다.\
**1Gbps를 꽉 채운 데이터를 보내는 건 실패**한다는 것.

## 5. 결론: 안정적인 1GbE로의 회귀

이게 **드라이버의 문제**인지, **H/W 적인 오류**인지를 근본적으로 찾는 건 어려워 보인다.\
**어댑터 자체의 문제**인지 **USB 포트의 전력 이슈**인지 알 수도 없다.\
물론, **RTL8156B** 이후에 출시된 **RTL8156BG** 칩셋에서는 정상동작 하는지도 알 수 없다.

아무튼, 1Gbps가 불안정한 상황에서 2.5Gbps를 시도하는 건 아무런 의미가 없어보인다.\
그래서, **안정성**이 보장된 **NAS 내장 1GbE**를 사용하는 것으로 회귀했다.

어쨌거나, [이전 포스팅](/ittalk/Prepare_to_2.5Gbps/)의 과정을 거쳐 **1Gbps는 완벽하게 사용**할 수 있게 되었다.

덧1. 이후 **RTL8156BG** 제품 구매시 또 시도해볼 예정.\
덧2. 원작자도 **RTL8156GB**로 작업을 했었다고 함
