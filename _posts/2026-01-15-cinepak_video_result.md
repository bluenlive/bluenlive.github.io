---
layout: single
title: "AI를 활용한 cinepak 비디오 화질 개선 결과"
date: 2026-1-15 21:07:00 +0900
categories:
  - media
---

[이전 글](/media/cinepak_video_conv2/)에서 일일이 변환한 결과를 AI를 활용해서 화질을 개선해봤다.\
사용된 프로그램은 그 유명한 [Topaz Video](https://www.topazlabs.com/topaz-video){:target="_blank"}.

일단 **그 난리**를 치면서 변환한 원본은 아래와 같다.\
아주 오래된 **cinepak** 코덱 답게 원본의 화질은 대단히 거칠다.\
해상도 역시 **318×238**로 대단히 낮으며, **12FPS**의 낮은 프레임률을 갖고 있다.

{% include video id="06qeC8hS4mE" provider="youtube" %}

일단 이 비디오를 **Theia 모델**로 화질을 개선해봤다.\
Topas Video는 결코 **저렴한 프로그램은 아니지만**, 일단 돌려보면 **효과는 확실**하다.

{% include video id="Qgljti1ZthQ" provider="youtube" %}

이 영상을 **Starlight 모델**로 돌리면 결과는 아래와 같다.\
하는 김에 프레임률 역시 **24FPS**로 두 배 뻥튀기 했다.

{% include video id="_taMYI5IR-Q" provider="youtube" %}

AI 기술이 역시 대세는 대세다... ㄷㄷㄷ
