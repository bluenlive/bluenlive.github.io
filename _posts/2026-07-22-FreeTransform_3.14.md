---
layout: single
title: "Paint.NET 자유 변형(Free Transform) 플러그인 3.14 업데이트"
date: 2026-7-22 22:15:00 +0900
categories:
  - MyProgram
---

## 개요

[2020년에 Paint.NET 용 자유 변형 플러그인을 제작해서 공개](https://teus.tistory.com/669)했었다.\
포토샵의 기능들 중에 이것만은 **대체 프로그램을 찾을 수 없었기 때문**이었다.

처음 개발 목적은 이미 왜곡된 이미지를 사각형으로 원복하는 것이었다.\
이후 프로그램이 정방향(Forward), 역방향(Backward) 변형 기능을 모두 갖도록 수정했다.

이 프로그램은 특성 상 구현 이후는 특별히 업데이트 할 일이 없는 편이다.\
그런데, 조금씩 손을 대다보니 꽤 많은 수정이 쌓였다.

## 다운로드 및 설치

이 프로그램 설치는 무척 간단하다.\
다운 받은 파일을 압축을 푼 뒤 Paint.NET 설치 폴더 아래의 Effects 폴더에 저장하면 설치된다.
통상적인 위치는 `C:\Program Files\Paint.NET\Effects`.

다운은 아래 링크에서 받을 수 있다.

{% include bnl_download-box.html
   file="/attachment/2026-07-22/FreeTransform3.rar"
   password="teus.me" %}

## 간단한 사용법

이미지를 연 뒤 `효과`-`비틀기`-`FreeTransform3`를 선택하면 된다.\
역방향은 **이미 왜곡된 이미지에서 사각형으로 복원할 때** 사용한다.\
여기서는 역방향만 설명한다.

아래와 같은 이미지가 있을 때…

![image](/images/2026-07-22/source_okl_s64.webp)
*〈007 살인면허〉 스팅어 미사일 장면 스토리보드*

필터에서 **펴고 싶은 네 지점을 선택**한다.

![image](/images/2026-07-22/step1_okl_s64.webp)

`quick and dirty` 모드를 선택하면 화질은 거칠지만 굉장히 빠르게 **원복된 preview**를 보여준다.\
**적절하게 선을 그어주는 것**은 덤이다.

여기서 Aspect Ratio를 지정할 수도 있다.

{: .bluebox-blue}
- 이미지의 각도를 통해 최대한 종횡비를 추정(`Auto`)해줌
- 3:2, 16:9, A4 등 자주 쓰이는 규격 비율 프리셋을 직접 선택할 수 있음
- Auto 모드에서는 자동 계산 결과에 **수동으로 가중치를 부여**하는 기능도 지원함

![image](/images/2026-07-22/step2_okl_s64.webp)

원하는 결과가 나왔으면 `High Quality` 모드를 선택한다.\
기존 버전에 구현했던 `Spline64`에 **고화질 FSAA** 기능을 추가했다.

![image](/images/2026-07-22/step3_okl_s64.webp)

이렇게 복원된 원본은 아래와 같다.

![image](/images/2026-07-22/final_okl_s64.webp)

## 히스토리

{: .bluebox-history}
- 2026.7.22: v3.14
  - **현대적 아키텍처 재구축**
    - .NET 9로 전환
    - 최신 `PropertyBasedBitmapEffect` 및 `ColorBgra32`로 마이그레이션
    - 코드 서명 적용
  - **렌더링 성능 대폭 향상**
    - 8x8 투사 행렬 사전 연산/전역 캐싱 구현
    - 보간 파이프라인 `float` 중심 최적화
    - 경계 체크 Fast-path 도입으로 오버헤드 최소화
  - **안내선 렌더링 초고속화**
    - GDI+ 의존성 제거
    - DDA 1D 궤적 추적
    - SIMD 스캔라인 메모리 복사 적용으로 고해상도 처리 속도 극대화
  - **화질 및 보간 알고리즘 개정**
    - 서브픽셀 안티앨리어싱(2x RGSS, 4x SSAA) 도입
    - Spline36 수식 교정 및 보간 옵션 통합
  - **역방향 변형 종횡비 제어 고도화**
    - 소실점 기반 메트릭 복원 및 교차비 Fallback 결합으로 `Auto` 종횡비 추정 정밀도 고도화
    - 캔버스 영역 초과 시 비율 왜곡을 방지하는 Uniform Downscaling 제어 적용
    - 주요 규격 프리셋(1:1, 3:2, 4:3, 16:9, 2.35:1, A4) 추가
  - **UI 및 사용성 개선**
    - 탭 컨트롤 UI 도입
    - 각도 단위 세분화(0.25도)
    - 안내선 굵기/간격 미세 조절 기능 추가
