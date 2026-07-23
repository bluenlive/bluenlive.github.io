---
layout: single
title: "Paint.NET QuadDroste 플러그인 1.05 공개"
date: 2026-7-23 09:26:00 +0900
categories:
  - MyProgram
---

## 개요

[이전 포스팅](/algorithm/QuadDroste/)에서 얘기했듯이, QuadDroste 플러그인을 만들었다.\
찾아보면 Paint.NET 플러그인이 있긴 하지만, 20년 전부터 만들고 싶었던 것이라 직접 만들었다.

20년 전, 처음 이 내용을 접했을 때의 나보다는 더 많은 수학 지식을 쌓았지만 여전히 100% 이해는 어려웠다.\
어영부영 만든 시험 버전도 별도의 GUI가 없어 번잡한 과정을 거쳐야 이미지를 볼 수 있었다.\
하지만 지금은 **AI라는 훌륭한 도우미**가 있고, **Paint.NET 이라는 환경**도 있다.

## 다운로드 및 설치

이 프로그램 설치는 무척 간단하다.\
다운 받은 파일을 압축을 푼 뒤 Paint.NET 설치 폴더 아래의 Effects 폴더에 저장하면 설치된다.
통상적인 위치는 `C:\Program Files\Paint.NET\Effects`.

다운은 아래 링크에서 받을 수 있다.

{% include bnl_download-box.html
   file="/attachment/2026-07-23/QuadDroste_1.05.rar"
   password="teus.me" %}

## 간단한 사용법

이미지를 연 뒤 **`효과`-`비틀기`-`QuadDroste…`**를 선택하면 된다.

`Quadrilateral`, `Circular`라는 두 개의 탭이 있다.\
간단하게 말해 각각 **사각**, **원형** 모드.

![image](/images/2026-07-23/quaddroste_B_okl_l3_Q.webp)

**사각 모드**에서는 **회전을 시킬 영역의 네 꼭짓점을 선택**하고, **원형 모드**에서는 **영역의 중심과 반경을 선택**한다.\
그 외에 UI를 보면서 선택할 내용들을 선택하고 `Render Mode`를 변경하면 Droste 효과를 볼 수 있다.

더 긴 설명을 쓸 수도 있지만, 이 필터야말로 **백문이 불여일런(Run)**이다.\
직접 써보시고 아름다운 Droste의 세상으로 들어오길 바란다.

## 히스토리

{: .bluebox-history}
- 2026.7.10: v1.00
  - 최초 구현
  - Buggy but just working
- 2026-07-23: v1.05
  - 복소 등각 나선 매핑 정합 및 원형 모드 기하학 완성
  - 중앙부 무한 수축 화질 대폭 개선
  - 밉맵 및 Screen-Space FSAA(2x RGSS, 4x SSAA) 고화질 안티앨리어싱 도입
  - 대형 이미지 고속 처리를 위한 1D 핀포인트 순방향 선분 추적 래스터라이제이션 도입
