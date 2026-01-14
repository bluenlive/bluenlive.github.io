---
layout: single
title: "cinepak mov 파일 수작업 변환 삽질기 추가"
date: 2026-1-14 23:54:00 +0900
categories:
  - media
---

[이전 글](/media/cinepak_video_conv/)에서 언급했던 비디오 파트를 수작업 해봤다.\
실제로 작업을 해보니 왜 ffmpeg에서 미묘하게 싱크 오류가 발생했는지 알 수 있었다.

비디오를 완벽하게 재인코딩 하려면 모든 프레임을 다 추출한 뒤에 각 프레임의 시간을 지정하면 된다.

각 프레임을 하나씩 추출하는 최적의 도구는 [VirtualDub2](https://sourceforge.net/p/vdfiltermod/wiki/Home/){:target="_blank"}이다.\
원조 [VirtualDub](https://www.virtualdub.org/){:target="_blank"}를 훌륭하게 계승한 이 프로그램은 전 프레임을 이미지로 손쉽게 저장해준다.

그리고, 프로그램을 하나 만들어서 `ffprobe`로 추출한 프레임 정보를 지정하면 큰 준비는 끝이다.

그런데...

{% highlight text hl_lines="4" %}
codec_type,stream_index,pts,pts_time,dts,dts_time,duration,duration_time,size,pos,flags
(생략)
video,0,41700,69.500000,41700,69.500000,60,0.100000,6532,9738127,___
video,0,41760,69.600000,41760,69.600000,60,0.100000,22664,9744659,KD_
video,0,41743,69.571667,41743,69.571667,60,0.100000,22664,9744659,K__
video,0,41803,69.671667,41803,69.671667,60,0.100000,3744,9767323,___
(생략)
{% endhighlight %}

추출된 정보를 보다 보면 뭔가 좀 정신이 아득해지는(?) 지점들이 등장한다.

`flags`에 `KD_`로 표시된 부분은 버려도 되는 부분들이다.\
즉, **프레임 내용은 있으나 재생 시에는 재생할 필요가 없는** 영상이다.\
`pts_time`\(표시 시간\)을 보면 **이전의 프레임을 덮어쓰는** 것을 확인할 수 있다.\
아마도, 잘라붙이는 과정에서 깔끔하게 날리지 못한 결과인 것 같다.

`ffmpeg`으로 VFR[^1]로 재인코딩 하기 위해서는 정확한 프레임 정보가 기록된 아래와 같은 텍스트 파일을 만들어야 한다.

```text
file 'frame0.png'
duration 0.200
file 'frame1.png'
duration 0.299
file 'frame2.png'
duration 0.501
(생략)
```

이 파일을 생성할 때, 저러한 프레임에 대해서는 기록하지 않고, 프레임 지속시간을 역셈하여 다시 기록한다.\
이렇게 하면 **싱크 오류를 원천적으로 차단**할 수 있다.

[^1]: Variable Frame Rate, 가변 프레임률
