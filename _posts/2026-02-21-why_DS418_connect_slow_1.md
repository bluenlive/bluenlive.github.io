---
layout: single
#classes: wide
title: "시놀로지 속도 이슈 #1꞉ 왜 100Mbps인가?"
date: 2026-2-21 23:30:00 +0900
categories:
  - ITTalk
---

## 1. 발단: 왜 NAS 파일 복사 속도가 왜 100Mbps(11MB/s)밖에 안 나올까?

집안 네트워크 환경은 **1Gbps**이고, 최근엔 굳이 NAS와 PC 간의 연결 속도를 측정하지 않았다.\
처음 구축할 때 충분히 테스트를 했으니...

그러다 며칠 전 뭔가 느낌이 이상해서 파일 복사 속도를 보니 **100Mbps** 정도였다.

![image](/images/2026-02-21/100Mbps_okl_s64_Q.png){: .align-center}
*Holy mother… 100메가…*

**NAS** 쪽을 확인해보니 링크 속도가 **1Gbps**로 나온다.\
그렇다면 범인은 PC다.

![image](/images/2026-02-21/eth100_Q.png){: .align-center}
*이걸 왜 눈치 못 챘지?*

**PC**의 링크 속도가 **100Mbps**로 되어있었던 것이다.\
네트워크 드라이버를 업데이트 해봤지만, 아무런 소용이 없었다.

확인 결과 범인은 **이더넷 케이블**.\
CAT.6라고 적어뒀지만 실상은 **CAT.6이 아니었던** 것이다.

케이블을 **다른 CAT.6 케이블로 교체**하자 링크 속도 문제가 해결됐다.

![image](/images/2026-02-21/eth1000_Q.png){: .align-center}
*반갑다 1000Mbps*

## 2. 전개: 링크는 1Gbps인데, SFTP 속도는 왜 이래?

케이블을 교체한 후 링크는 1Gbps가 되었다.\
그런데, 파일을 복사해보니 전송 속도는 여전히 **500Mbps** 수준에 머물고 있다.

![image](/images/2026-02-21/500Mbps_okl_s64_Q.png){: .align-center}
*저기… 킹깐만요… 킹받네…*

이 폴더는 NAS에서 **SFTP**로 설정한 디렉토리를 [RaiDrive](https://www.raidrive.com/){:target="_blank"}로 연결한 곳이다.\
즉, 원인으로 추정할 수 있는 곳들이 다음과 같은 것이다.

{: .bluebox-blue}
* SFTP의 암호화 고유의 오버헤드
* ARM 프로세서(RTD1296)의 암호화 오버헤드
* RaiDrive S/W 오버헤드

SFTP는 안전하지만 좀 비효율적으로 암호화를 수행한다.\
이걸 일단 범인으로 추정하고 **WebDAV(HTTPS/TLS)**로 연동해봤다.

![image](/images/2026-02-21/1Gbps_okl_s64_Q.png){: .align-center}
*그렇지! 이거지!*

드디어 **1Gbps**로 파일을 읽고 쓰는 것을 확인했다.

### 2.1 왜 WebDAV가 SFTP보다 훨씬 빠르지?

* **암호화 터널 vs 개별 포장박스:**
WebDAV는 **전송 계층(L4)**에서 **TLS 암호화 터널**을 먼저 구축한 뒤 데이터를 밀어넣는 방식이다.\
반면, SFTP는 **응용 계층(L7)**에서 패킷 하나하나를 암호화 박스에 담고 무결성을 검증한다.
* **하드웨어 가속(AES-GCM)의 효율:**
DS418의 ARMv8 CPU는 암호화 가속 엔진을 탑재하고 있다.\
WebDAV(HTTPS)가 사용하는 **AES-GCM** 은 이 가속 엔진을 효율적으로 활용한다.\
반면 SFTP는 암호화와 무결성 확인(HMAC)을 따로 계산해야 하는 경우가 많아 연산량이 늘어난다.
* **ACK 응답의 '수다스러움':**
SFTP는 본질적으로 매우 수다스러운 프로토콜이다.
작은 블록을 보낼 때마다 "ACK 응답"을 기다리고, 이게 성능에 영향을 미친다.

{% include bluenlive/postit.html content="**교훈:** 네트워크는 물리적 선만 바꾼다고 끝나는 것이 아니라, **프로토콜과 CPU 자원까지 고려**가 필수임" %}
