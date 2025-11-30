---
layout: single
#classes: wide
title: "구라제거기(키보드 보안 프로그램 삭제) 7.32 업데이트"
date: 2024-5-1
categories:
  - HoaxEliminator
tags: ["activex","nProtect","구라제거기","뱅킹","보안","안랩"]
---

<div style="border-style: dashed; border-width: 1px; border-color: #79a5e4; background-color: #dbe8fb; padding: 10px;"><p style="text-align: center; margin-bottom: 0;"><span style="font-size: 1.111em;"><b><a href="/hoaxeliminator/HoaxEliminator7.34/">새 버전</a>이 나왔습니다. <a href="/hoaxeliminator/HoaxEliminator7.34/">새 버전</a>을 사용해주시기 바랍니다.</b></span></p></div><p><br /></p>

PC 뱅킹의 주적은 **PC 뱅킹 프로그램**이다.

PC 뱅킹을 하고 나면 컴퓨터가 미친 듯이 느려지기 때문이다.\
**키보드 보안 프로그램**을 필두로 컴퓨터를 느려지게 만드는 악의 무리들이 너무나 많다.\
전통의 명가(?) **nProte∗∗** 부터 컴퓨터 발목잡기의 거목 **안∗ 온라인 시큐∗∗**, 그 외에도 수많은 잡 구라들…

[KISA에서 I사 보안모듈 프로그램에 문제가 있다고 발표](http://www.etnews.com/20161130000139){:target="_blank"}할 정도로 **완성도가 엉망**인 경우도 있다.\
**보안 취약점을 갖고있는 보안 프로그램**이라니… 무슨 [열림교회 닫힘](https://www.google.com/search?q=열림교회+닫힘){:target="_blank"}도 아니고…

더군다나 이런 프로그램들은 몰래 설치가 되는 것도 아니고 아예 **(강제로) 동의를 받아** 설치된다.\
마치 건물 철거 강제 집행하면서 동의서 서명당하는 기분이다.

게다가 [보안 전문가인 블라디미르 팔란트 씨의 글](https://github.com/alanleedev/KoreaSecurityApps/blob/main/03_weakening_tls_protection.md){:target="_blank"}에 따르면 이 과정에서 설치된 루트 인증서를 제대로 삭제하지도 않는다.

그래서 간단히 만들었다.\
설치 프로그램 목록에서 이러한 **백해무익한 쓰레기들을 찾아서 한방에 제거**해주는 프로그램.

이번 7.x대에서는 **업데이트 여부를 확인**하는 기능을 추가했고, 7.10에서는 **루트 인증서를 확인**하는 기능을 추가했으며, 7.16에서는 목록들을 **정렬**하는 기능을 추가했다.

그리고, 7.17에서는 후원 계좌를 띄우지 않고 [토스 아이디를 통해 후원](https://toss.me/bluenlive){:target="_blank"}받도록 수정했다.

![image](/images/2024-01-01/hoax.png){: .align-center}

이 프로그램을 실행하면 위와 같은 화면이 나온다.

PC에 설치된 프로그램들 중에 제거해야 될 프로그램들의 목록을 띄워준 것이다.\
여기서 **일부를 선택**해서 제거를 클릭해도 되고, 그냥 **모두 제거**를 클릭해도 된다.

클릭하면 지정된 프로그램들을 하나씩 제거할 수 있는 배치 파일을 만들고 실행해서 몽땅 제거해준다.

화면에 다이얼로그가 뜨면 하나씩 확인 버튼만 클릭하면 된다.

이 프로그램은 아래 링크에서 다운받을 수 있다.\
x86과 x64 버전이 함께 들어있는데, 64비트 환경이라면 x64 버전을 추천한다.

{% include bluenlive/download-box.html
   file="/attachment/2024-01-02/HoaxEliminator7.32.zip"
   password="teus.me" %}

## 히스토리

* 2024.1.1: v7.25
  * 대상 프로그램 추가
    * Char∗∗∗ Eng∗∗∗
    * Cl∗∗∗Pl∗∗ 2.∗
    * s∗∗Tr∗∗∗
    * S∗∗In∗∗

* 2024.1.27: v7.27
  * 대상 프로그램 추가
    * Sm∗∗∗AIB∗∗∗ St∗∗∗U∗
  * 라이브러리 업데이트
    * Google/RE2를 2024.2.1 버전으로 업데이트
    * Google/Abseil을 20240116.0 버전(Abseil LTS branch, Jan 2024)으로 업데이트
  * 프로그램에 표시되는 링크 주소 변경

* 2024.4.5: v7.30
  * 라이브러리 업데이트
    * Google/RE2를 2024.4.1 버전으로 업데이트

* 2024.4.14: v7.31
  * 대상 프로그램 추가
    * Tr∗∗∗Docum∗∗∗V∗.∗ Cli∗∗∗ for Wind∗∗∗ Ag∗∗∗ Non-Act∗∗∗ X ∗.∗.∗.∗
    * TSX∗∗Tool∗∗∗ ∗.∗.∗.∗
    * TSX∗∗Tool∗∗∗
    * T∗Tool∗∗∗
    * REDBC Tr∗∗∗W∗∗ Cont∗∗∗
    * Fi∗∗G∗∗∗
  * 라이브러리 업데이트
    * Google/Abseil을 20240116.2 버전(Abseil LTS branch, Jan 2024, Patch 2)으로 업데이트

* 2024.5.1: v7.32
  * 대상 프로그램 추가
    * Tra∗∗Arm∗∗ Vie∗∗∗
    * Se∗∗T∗∗ NXS
    * C∗∗∗B2B ExE∗∗∗
  * 라이브러리 업데이트
    * Google/RE2를 2024.5.1 버전으로 업데이트
