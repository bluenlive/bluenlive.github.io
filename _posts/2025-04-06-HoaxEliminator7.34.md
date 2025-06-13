---
layout: single
#classes: wide
title: "구라제거기(키보드 보안 프로그램 삭제) 7.42 업데이트"
date: 2025-4-6 22:35:00 +0900
categories:
  - HoaxEliminator
tags: ["activex","nProtect","구라제거기","뱅킹","보안","안랩"]
---

PC 뱅킹의 주적은 **PC 뱅킹 프로그램**이다.

PC 뱅킹을 하고 나면 컴퓨터가 미친 듯이 느려지기 때문이다.  
**키보드 보안 프로그램**을 필두로 컴퓨터를 느려지게 만드는 악의 무리들이 너무나 많다.  
전통의 명가(?) **nProte∗∗** 부터 컴퓨터 발목잡기의 거목 **안∗ 온라인 시큐∗∗**, 그 외에도 수많은 잡 구라들…

[KISA에서 I사 보안모듈 프로그램에 문제가 있다고 발표](http://www.etnews.com/20161130000139){:target="_blank"}할 정도로 **완성도가 엉망**인 경우도 있다.  
**보안 취약점을 갖고있는 보안 프로그램**이라니… 무슨 [열림교회 닫힘](https://www.google.com/search?q=열림교회+닫힘){:target="_blank"}도 아니고…  

더군다나 이런 프로그램들은 몰래 설치가 되는 것도 아니고 아예 **(강제로) 동의를 받아** 설치된다.  
마치 건물 철거 강제 집행하면서 동의서 서명당하는 기분이다.

게다가 [보안 전문가인 블라디미르 팔란트 씨의 글](https://github.com/alanleedev/KoreaSecurityApps/blob/main/03_weakening_tls_protection.md){:target="_blank"}에 따르면 이 과정에서 설치된 루트 인증서를 제대로 삭제하지도 않는다.

그래서 간단히 만들었다.  
설치 프로그램 목록에서 이러한 **백해무익한 쓰레기들을 찾아서 한방에 제거**해주는 프로그램.

7.34부터는 디자인을 수정하고 있다.  
아이콘을 포함한 디자인은 **현역 광고 감독**님이신 [LSM](http://www.leeseungmin.com/){:target="_blank"}님께서 지원해주시고 계신다.  
이 프로그램은 Win32 API의 기능만을 사용하기 때문에 디자인에 대한 제약이 있지만, 최대한 노력해주고 계신다.

그리고, 7.17부터 띄웠던 [토스 아이디](https://toss.me/bluenlive){:target="_blank"}는 서비스 종료로 [Buy Me A Coffee](https://buymeacoffee.com/bluenlive){:target="_blank"}로 변경되었다.

![image](/images/2025-04-06/hoax_Bs64_Q.png){: .align-center}
*창의 디자인은 지속적으로 바뀔 예정*

이 프로그램을 실행하면 위와 같은 화면이 나온다.

PC에 설치된 프로그램들 중에 제거해야 될 프로그램들의 목록을 띄워준 것이다.  
여기서 **일부를 선택**해서 제거를 클릭해도 되고, 그냥 **모두 제거**를 클릭해도 된다.

클릭하면 지정된 프로그램들을 하나씩 제거할 수 있는 배치 파일을 만들고 실행해서 몽땅 제거해준다.

화면에 다이얼로그가 뜨면 하나씩 확인 버튼만 클릭하면 된다.  

이 프로그램은 아래 링크에서 다운받을 수 있다.  
x86과 x64 버전이 함께 들어있는데, 64비트 환경이라면 x64 버전을 추천한다.

<div style="text-align: center;" markdown="1">
[Download HoaxEliminator7.42.zip](</attachment/2025-04-06/HoaxEliminator7.42.zip>){: .btn .btn--info .btn--x-large}
<br>password꞉ <span style="color: red; font-size: 1.5em;"><b>teus.me</b></span>
</div>

## 히스토리

* 2024.7.6: v7.34
  * UI 수정 준비
  * 대상 프로그램 추가
    * So∗∗Ca∗∗ Sec∗∗∗Web Mul∗∗ Brow∗∗∗ Pack∗∗∗
    * We∗Cu∗∗
    * weh∗∗∗ag∗∗∗
    * BG∗
    * Inz∗∗Fo∗∗ ∗.∗
    * Docul∗∗∗ Rea∗∗∗
  * 라이브러리 업데이트
    * Google/RE2 라이브러리를 2024.7.2 버전으로 업데이트

* 2024.7.7: v7.35
  * 잘못된 첨부 파일 교체

* 2025.4.6: v7.42
  * 아이콘 변경
  * TOSS ID 에서 Buy Me A Coffee로 변경
  * 대상 프로그램 추가
    * Bo∗∗L∗∗ - Bo∗∗L∗∗ for Desk∗∗∗
    * Relev∗∗∗Knowle∗∗∗
    * Prem∗∗∗Opin∗∗∗
    * yessearc∗∗∗ Uninst∗∗∗
    * NE∗∗ 인∗∗ 로∗∗ 프로∗∗
    * 스∗∗공동∗∗
  * 대상 프로그램 삭제
    * Ht∗∗T∗U∗∗Brid∗∗
  * 라이브러리 업데이트
    * LZ4 업데이트: v1.10.0 - Multicores edition
    * Google/Abseil 라이브러리를 20250127.1 버전(Abseil LTS branch, January 2025, Patch 1)으로 업데이트
  * 스펙터 완화 옵션 제거
  * 진입접 (wWinMainCRTStartup) 옵션 제거
