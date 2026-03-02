---
layout: single
#classes: wide
title: "시놀로지 속도 이슈 #3꞉ 희망고문의 끝"
date: 2026-3-3 0:0:00 +0900
categories:
  - ITTalk
series: "Synology_NAS_Speed_Issue"
series_title: "시놀로지 NAS 접속 속도 이슈"
---

## 6. 재도전: RTL8156BG는 어떨까?
지난 테스트에서 **RTL8156B** 칩셋의 수신(RX) 오류 발생 이후, 후속 모델인 **RTL8156BG** 칩셋 제품을 구매했다.

이전 모델보다 전력 효율이 개선되어 발열이 적고 안정적이라는 얘기가 있어, 기대해도 될 것 같았다.\
드라이버는 이전 버전 그대로, 포트는 NAS 후면 USB 포트를 사용했다.

![image](/images/2026-03-03/20260301_092855023_iOS_okl_s64.jpg)
*믿는다 UGREEN, 믿는다 RTL8156BG*

## 7. 검증: 돌다리도 두드려보자
테스트 목적은 간단하다.\
허브가 1GbE라서 1Gbps까지밖에 사용할 수 없으니, 이 대역을 안정적으로 소화하는지 확인하는 것.

### 1단계: PC → NAS 송신 (TX) 테스트
먼저 10분(600초)간의 장기 테스트를 진행했다.

```bash
iperf3 -c 172.∗∗.∗.∗∗∗ -t 600

```

결과는 당연히도(?) 완벽했다. 10분 내내 **949 Mbits/sec**를 칼같이 유지했다.\
그런데, 이건 RTL8156B에서도 잘 동작했었기 때문에 기대했던 결과다.

```text
C:\Users\bluen>iperf3 -c 172.**.*.*** -t 600
Connecting to host 172.**.*.***, port 5201
[  5] local 172.**.*.** port 6209 connected to 172.**.*.*** port 5201
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.01   sec   118 MBytes   980 Mbits/sec
[  5]   1.01-2.01   sec   114 MBytes   949 Mbits/sec
[  5]   2.01-3.01   sec   113 MBytes   950 Mbits/sec
[  5]   3.01-4.01   sec   113 MBytes   948 Mbits/sec
                        ⋮
                        ⋮
[  5] 596.00-597.00 sec   113 MBytes   948 Mbits/sec
[  5] 597.00-598.00 sec   113 MBytes   950 Mbits/sec
[  5] 598.00-599.00 sec   113 MBytes   949 Mbits/sec
[  5] 599.00-600.00 sec   113 MBytes   949 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-600.00 sec  66.3 GBytes   949 Mbits/sec                  sender
[  5]   0.00-600.02 sec  66.3 GBytes   949 Mbits/sec                  receiver

iperf Done.
```

### 2단계: NAS → PC 수신 (RX) 테스트
문제의 수신 테스트. 지난번엔 **2초만에 뻗어버렸던** 그 구간이다.\
이번엔 신중하게 10초, 60초 단발성 테스트부터 진행했다.

```bash
iperf3 -c 172.∗∗.∗.∗∗∗ -t 60 -R

```

결과는 훌륭했다.\
**1분간 1Gbps**의 속도를 **문제 없이 유지**하고 있었다.

```text
C:\Users\bluen>iperf3 -c 172.**.*.*** -t 60 -R
Connecting to host 172.**.*.***, port 5201
Reverse mode, remote host 172.**.*.*** is sending
[  5] local 172.**.*.** port 4082 connected to 172.**.*.*** port 5201
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.01   sec   108 MBytes   902 Mbits/sec
[  5]   1.01-2.01   sec   113 MBytes   949 Mbits/sec
[  5]   2.01-3.01   sec   113 MBytes   945 Mbits/sec
[  5]   3.01-4.01   sec   113 MBytes   945 Mbits/sec
                        ⋮
                        ⋮
[  5]  56.00-57.01  sec   112 MBytes   938 Mbits/sec
[  5]  57.01-58.00  sec   113 MBytes   948 Mbits/sec
[  5]  58.00-59.00  sec   111 MBytes   932 Mbits/sec
[  5]  59.00-60.00  sec   113 MBytes   948 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-60.00  sec  6.61 GBytes   946 Mbits/sec    0            sender
[  5]   0.00-60.00  sec  6.60 GBytes   945 Mbits/sec                  receiver

iperf Done.
```

평균 **945 Mbits/sec**. 약간의 변동은 있었지만 `Retr 0`을 기록하며 무사히 통과했다.\
칩셋의 전력 효율 개선이 효과를 보는 듯했다.

## 8. 절망: 40초의 벽

마지막으로 송신 때와 동일한 조건인 **10분 장기 수신 테스트**에 돌입했다.\
이 고비만 넘기면 **2.5GbE스위칭 허브**를 주문할 생각이었다.

```bash
iperf3 -c 172.∗∗.∗.∗∗∗ -t 600 -R

```

하지만… 희망은 **40초**를 버티지 못했다.

```text
C:\Users\bluen>iperf3 -c 172.**.*.*** -t 600 -R
Connecting to host 172.**.*.***, port 5201
Reverse mode, remote host 172.**.*.*** is sending
[  5] local 172.**.*.** port 9882 connected to 172.**.*.*** port 5201
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.01   sec   113 MBytes   939 Mbits/sec
[  5]   1.01-2.01   sec   113 MBytes   944 Mbits/sec
[  5]   2.01-3.01   sec   113 MBytes   949 Mbits/sec
[  5]   3.01-4.01   sec   112 MBytes   943 Mbits/sec
                        ⋮
                        ⋮
[  5]  37.01-38.01  sec   113 MBytes   943 Mbits/sec
[  5]  38.01-39.01  sec   52.8 MBytes   444 Mbits/sec
[  5]  39.01-40.01  sec   0.00 Bytes  0.00 bits/sec
[  5]  40.01-41.00  sec   0.00 Bytes  0.00 bits/sec
[  5]  41.00-42.00  sec   0.00 Bytes  0.00 bits/sec
                        ⋮
```

약 38초 지점에서 속도가 반 토막 나더니, 39초부터는 데이터 전송이 완전히 끊겨버렸다.\
칩셋을 최신형인 **BG**로 바꿔도 시놀로지 환경에서 USB를 통한 대량의 수신 데이터 처리는 **근본적인 호환성 이슈**가 있음을 다시 한번 확인했다.

## 9. 최종 결론: 끝내 돌아온 순정

근본적인 원인은 알 수 없지만, 시놀로지와 USB 이더넷 사이에선 **연동이 완벽하지 않다**는 것을 확인했다.\
긴 시간 씨름했지만, 이로써 **2.5Gbps에 대한 미련은 완전히 접기로** 했다.

참고 삼아 순정 이더넷 포트에 대해 동일한 테스트를 수행해봤다.\
결과는 아래와 같다.\
**역시 순정이 최고**다.

```text
C:\Users\bluen>iperf3 -c 172.**.*.*** -t 600 -R
Connecting to host 172.**.*.***, port 5201
Reverse mode, remote host 172.**.*.*** is sending
[  5] local 172.**.*.** port 5016 connected to 172.**.*.*** port 5201
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.01   sec   114 MBytes   947 Mbits/sec
[  5]   1.01-2.00   sec   112 MBytes   949 Mbits/sec
[  5]   2.00-3.02   sec   114 MBytes   948 Mbits/sec
[  5]   3.02-4.00   sec   110 MBytes   934 Mbits/sec
                        ⋮
                        ⋮
[  5] 596.01-597.01 sec   113 MBytes   949 Mbits/sec
[  5] 597.01-598.00 sec   113 MBytes   949 Mbits/sec
[  5] 598.00-599.00 sec   113 MBytes   949 Mbits/sec
[  5] 599.00-600.00 sec   113 MBytes   950 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-599.99 sec  66.2 GBytes   947 Mbits/sec    0            sender
[  5]   0.00-600.00 sec  66.1 GBytes   947 Mbits/sec                  receiver

iperf Done.
```
