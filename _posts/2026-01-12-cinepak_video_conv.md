---
layout: single
title: "cinepak mov 파일 수작업 변환 삽질기"
date: 2026-1-12 14:58:00 +0900
categories:
  - media
---

애플 기종에서 사용되는 비디오 파일의 확장자는 `.mov`이다.\
이 확장자는 무려 1991년 Quicktime 1.0부터 사용되어왔다.

하지만, 파일의 내부 포맷은 초기와 완전히 달라졌다.\
퀵타임 3.0에 들어서야 현재의 ATOM 기반 구조가 채택되었다.\
후에 이를 기반으로 `MPEG‑4 Part 14 (MP4)`[^1]가 만들어진 것.

처음부터 애플은 퀵타임을 단순한 동영상 저장 뿐 아니라 유연한 편집이 가능하도록 만들기를 원했었다.\
지금의 기술로는 너무도 당연한 것 같지만, 1991년이면 **동영상의 존재** 자체가 혁신적이던 시절이었다.

이러한 편집이 생각보다 쉽지 않은 것이 **비디오/오디오 싱크**가 생각보다 쉬운 기술이 아니기 때문이다.\
`.mkv`, `.mp4` 등의 현재 비디오에서 이런 문제가 없는 건 **그동안의 수많은 시행착오의 결과물**인 것.

## 오래된 cinepak 비디오 변환

예전 자료 중에 **cinepak**으로 만들어진 퀵타임 파일이 있었다.\
AI를 활용해서 비디오 품질도 끌어올리는 요즘 시기에 한번 쯤 변환해보고 싶어졌다.

동영상의 정보는 아래와 같다.

{% highlight bash hl_lines="15 35 42 43 44" %}
General
Complete name                            : H:\encoding_ai\LQ\CHAPTER1.MOV
Format                                   : QuickTime
Format/Info                              : Original Apple specifications
File size                                : 112 MiB
Duration                                 : 14 min 8 s
Overall bit rate                         : 1 102 kb/s
Frame rate                               : 9.638 FPS
Encoded date                             : 1995-06-28 16:25:57 UTC
Tagged date                              : 1995-06-28 16:32:56 UTC
Writing library                          : Apple QuickTime

Video
ID                                       : 1
Format                                   : Cinepak
Codec ID                                 : cvid
Duration                                 : 14 min 8 s
Bit rate                                 : 1 013 kb/s
Width                                    : 318 pixels
Height                                   : 238 pixels
Display aspect ratio                     : 4:3
Frame rate mode                          : Variable
Frame rate                               : 9.638 FPS
Minimum frame rate                       : 0.909 FPS
Maximum frame rate                       : 10.000 FPS
Bits/(Pixel*Frame)                       : 1.388
Stream size                              : 102 MiB (92%)
Writing library                          : Cinepak
Language                                 : English
Encoded date                             : 1995-05-15 11:58:17 UTC
Tagged date                              : 1995-06-28 16:32:56 UTC

Audio
ID                                       : 2
Format                                   : PCM
Format settings                          : Little / Unsigned
Codec ID                                 : raw
Duration                                 : 14 min 8 s
Source duration                          : 14 min 8 s
Bit rate mode                            : Constant
Bit rate                                 : 88.2 kb/s
Channel(s)                               : 1 channel
Sampling rate                            : 11127
Bit depth                                : 8 bits
Stream size                              : 9.01 MiB (8%)
Source stream size                       : 9.00 MiB (8%)
Language                                 : English
Encoded date                             : 1995-05-15 11:58:17 UTC
Tagged date                              : 1995-06-28 16:32:56 UTC
{% endhighlight %}

무려 30년 전에 만들어진 **Cinepak**과 **8 bits, 1 channel 오디오**로 저장된 고색창연한 동영상이다.\
오디오의 샘플링 레이트는 듣도 보도 못한 **11,127Hz**이다.

이 영상을 변환해보면 일단 **오디오 싱크가 맞지 않는다**.\
비디오는 VFR로 표시가 되어있는데, 요즘 기술로 VFR로 만들어진 영상이 아니다.\
단지 영상을 편집하는 과정에서 time code 기준으로 잘라붙였고, 미묘하게 맞지 않아 VFR로 인식된 것이다.

이런 경우는 **FFmpeg**을 활용하면 꽤 잘 변환할 수 있다.\
원본 비디오를 최신 코덱으로 변환하면서 오디오를 강제변환하면 된다.

```bat
ffmpeg -i "CHAPTER1.MOV" -c:v libx264 -c:a aac -ar 44100 -b:a 256k -async 1 "CHAPTER1.mp4"
```

기본적으로는 이렇게 `-async 1` 옴션만 추가하면 잘라붙인 오디오를 깔끔하게 정리해준다.

## 그런데, 현실은?

그런데, 좀 이상하게 상황이 전개됐다.

분명히 비디오와 오디오의 전체 길이는 잘 맞는데, 싱크가 잘 맞지 않는다.\
아무래도 ffmpeg에서의 처리가 완벽하지는 않은 것 같다.

오디오를 수작업으로 변환하기로 했다.

일단 이 영상의 각 오디오 패킷의 시간 등을 정확히 확인해본다.

```bat
ffprobe -select_streams v -show_packets -of csv=p=0 "CHAPTER1.MOV" > "CHAPTER1.v.csv"
ffprobe -select_streams a -show_packets -of csv=p=0 "CHAPTER1.MOV" > "CHAPTER1.a.csv"
```

이렇게 실행하면 비디오/오디오에 대해 각각 아래와 같은 파일을 만들어준다.\
**헤더**는 따로 출력해주지 않아 **별도로 추가**했다.

```text
codec_type,stream_index,pts,pts_time,dts,dts_time,duration,duration_time,size,pos,flags
audio,1,0,0.000000,0,0.000000,1024,0.092028,1024,8,K__
audio,1,1024,0.092028,1024,0.092028,1024,0.092028,1024,1032,K__
audio,1,2048,0.184057,2048,0.184057,1024,0.092028,1024,2056,K__
audio,1,3072,0.276085,3072,0.276085,1024,0.092028,1024,3080,K__
audio,1,4096,0.368114,4096,0.368114,1024,0.092028,1024,4104,K__
audio,1,5120,0.460142,5120,0.460142,444,0.039903,444,5128,K__
audio,1,5564,0.500045,5564,0.500045,1024,0.092028,1024,5572,K__
audio,1,6588,0.592073,6588,0.592073,1024,0.092028,1024,6596,K__
audio,1,7612,0.684102,7612,0.684102,1024,0.092028,1024,7620,K__
audio,1,8636,0.776130,8636,0.776130,1024,0.092028,1024,8644,K__
audio,1,9660,0.868159,9660,0.868159,1024,0.092028,1024,9668,K__
audio,1,10684,0.960187,10684,0.960187,443,0.039813,443,10692,K__
(생략)
```

파일을 찬찬히 분석해보니 왜 싱크를 한방에 완벽하게 맞출 수 없는지 알 수 있었다.\
잘라붙인 구간이 너무 들쑥날쑥 했고, 심지어 영상이 잘못 겹쳐진 부분도 있었다.

비디오는 ffmpeg에게 무조건 맡길 수밖에 없지만, 오디오는 좀 다르다.\
포맷이 **8비트 PCM**이기 때문에 적절하게 헤더만 잘 씌우면 정확한 오디오를 만들 수 있다.

pts(Presentation Timestamp)을 기준으로 오디오 데이터만 추출해서 배치하면 된다.\
메모리에 `vector<uint8_t>` 하나 크게 잡아서 배치해주는 프로그램 하나 만들면 큰 작업은 끝이다.\
**WAVE 파일**을 생성하는 건 **헤더를 적절히 기록**하는 것 외엔 특별할 게 없다.

## 추가 작업 계획: 비디오

비디오는 ffmpeg이 상당히 잘 변환해줬다.\
그런데, 앞에서 언급했듯이 영상이 잘못 겹쳐진 부분이 있었다.

찬찬히 뜯어보니 ffmpeg에선 대충 덮고 넘어간 것 같은데, 이왕 삽질 하는 김에 끝까지 갈 예정.

ffmpeg에서는 원본 영상이 **이미지 파일들**인 경우 아래와 같이 지정하면 VFR 영상을 만들 수 있다.

```text
file 'frame0.png'
duration 0.200
file 'frame1.png'
duration 0.299
file 'frame2.png'
duration 0.501
(생략)
```

```bat
ffmpeg -f concat -i "frames.txt" -vsync vfr "output.mp4"
```

다음 단계로 앞에서 생성한 csv 파일을 이용해서 이 데이터를 생성해서 변환해볼 예정.

{% include bluenlive/quote.html
   align="center"
   content="그런데, 이 영상 그냥 유튜브 뒤지면 고화질 버전이 있을 것 같은데?" %}

[^1]: 다름 아닌, 우리가 알고 있는 `.mp4` 파일의 컨테이너 포맷
