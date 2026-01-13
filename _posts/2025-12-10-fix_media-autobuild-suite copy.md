---
layout: single
title: "media-autobuild_suite로 FDK AAC 인코더 빌드하기"
date: 2025-12-10 20:55:00 +0900
categories:
  - ITTalk
---

[**media-autobuild_suite**](https://github.com/m-ab-s/media-autobuild_suite){:target="_blank"}를 이용하면 [ffmpeg](https://ffmpeg.org/){:target="_blank"}를 원하는 대로 빌드할 수 있다.

하지만, 말이 쉽지 **ffmpeg을 원하는대로 모든 인코더를 지원하도록** 빌드하는 건 쉬운 일이 아니다.\
[이전 글](/ittalk/fix_media-autobuild-suite/)에서도 살짝 얘기했지만, 빌드에 실패하는 경우가 꽤 많다.

모든 게 가능하도록 빌드하는 것보단 **필요한 인코더만 빌드**하고, 배포판과의 **파이프라인으로 인코딩** 하는 게 효율적이다.

---

방향을 잡고 보면 **FDK AAC 인코더** 외에 **파이프라인**에 필요한 요소, **컨테이너 포맷**만 결정하면 된다.

이렇게 원하는 내용만으로 빌드하려면 일단은 통상적인 빌드 과정을 먼저 거쳐야 한다.\
최신 버전을 다운받은 뒤 다음과 같이 실행하면 된다.

```dos
media-autobuild_suite.bat
```

스크립트가 꽤 많은 질문을 하는데, 적절히 답하면 된다.\
32비트/64비트를 동시에 빌드할 수도 있지만, 요즘 32비트 윈도우 깔린 PC에서 인코딩 할 일이 있겠나[...]

적당히 빌드가 끝나면(실패해도 상관 없음) 이제 `ffmpeg_options.txt` 파일에서 원하는 항목들을 지정한다.\
파일 위치는 `build` 폴더에 있다.

- mp3 인코딩 추가
- 파이프라인을 tcp 및 udp 까지 지원할 수 있도록 함
- 오디오 디코더에 `pcm_*` 외에 `flac` 까지 추가
- 컨테이너 포맷으로 `mkv`, `mp4`, `m4a` 까지 적용

이 내용까지 담겨있는 `ffmpeg_options.txt`은 다음과 같다.

```text
# Minimal ffmpeg build focused on libfdk-aac
# Disable everything first, then enable only what is needed

--disable-autodetect
--disable-everything

# Encoders
--enable-libfdk-aac
--enable-libmp3lame
--enable-encoder=libfdk_aac
--enable-encoder=libmp3lame

# Decoders (raw video, raw audio via PCM, FLAC)
--enable-decoder=flac
--enable-decoder=pcm_s16le
--enable-decoder=pcm_s32le
--enable-decoder=pcm_f32le

# Demuxers (to accept raw streams and flac)
--enable-demuxer=flac
--enable-demuxer=wav

# Protocols (for TCP/IP streaming)
--enable-protocol=file
--enable-protocol=tcp
--enable-protocol=udp
--enable-protocol=pipe
--enable-protocol=fd

# Muxers (output containers)
--enable-muxer=matroska
--enable-muxer=mp4
--enable-muxer=ipod

# Libraries
--enable-swresample

# Audio filters
--enable-filter=aresample
--enable-filter=aformat
--enable-filter=anull
```

이 글을 포스팅하는 현재 기준으로 이렇게 하면 **5.1 MiB** 짜리 `ffmpeg.exe`이 만들어진다.\
그리고, 지원되는 인코더는 아래와 같이 확인할 수 있고,

```text
ffmpeg version N-122082-gcdb14bc74d Copyright (c) 2000-2025 the FFmpeg developers
  built with gcc 15.2.0 (Rev8, Built by MSYS2 project)
  configuration:  --pkg-config=pkgconf --cc='ccache gcc' --cxx='ccache g++' --ld='ccache g++' --extra-cxxflags=-fpermissive --extra-cflags=-Wno-int-conversion --disable-autodetect --disable-everything --enable-libfdk-aac --enable-libmp3lame --enable-encoder=libfdk_aac --enable-encoder=libmp3lame --enable-decoder=flac --enable-decoder=pcm_s16le --enable-decoder=pcm_s32le --enable-decoder=pcm_f32le --enable-demuxer=flac --enable-demuxer=wav --enable-protocol=file --enable-protocol=tcp --enable-protocol=udp --enable-protocol=pipe --enable-protocol=fd --enable-muxer=matroska --enable-muxer=mp4 --enable-muxer=ipod --enable-swresample --enable-filter=aresample --enable-filter=aformat --enable-filter=anull --enable-schannel --disable-stripping
  libavutil      60. 20.100 / 60. 20.100
  libavcodec     62. 22.101 / 62. 22.101
  libavformat    62.  6.103 / 62.  6.103
  libavdevice    62.  2.100 / 62.  2.100
  libavfilter    11. 10.101 / 11. 10.101
  libswscale      9.  3.100 /  9.  3.100
  libswresample   6.  2.100 /  6.  2.100
Encoders:
 V..... = Video
 A..... = Audio
 S..... = Subtitle
 .F.... = Frame-level multithreading
 ..S... = Slice-level multithreading
 ...X.. = Codec is experimental
 ....B. = Supports draw_horiz_band
 .....D = Supports direct rendering method 1
 ------
 A....D libfdk_aac           Fraunhofer FDK AAC (codec aac)
 A....D libmp3lame           libmp3lame MP3 (MPEG audio layer 3) (codec mp3)
```

디코더는 아래와 같이 확인할 수 있다.

```text
ffmpeg version N-122082-gcdb14bc74d Copyright (c) 2000-2025 the FFmpeg developers
  built with gcc 15.2.0 (Rev8, Built by MSYS2 project)
  configuration:  --pkg-config=pkgconf --cc='ccache gcc' --cxx='ccache g++' --ld='ccache g++' --extra-cxxflags=-fpermissive --extra-cflags=-Wno-int-conversion --disable-autodetect --disable-everything --enable-libfdk-aac --enable-libmp3lame --enable-encoder=libfdk_aac --enable-encoder=libmp3lame --enable-decoder=flac --enable-decoder=pcm_s16le --enable-decoder=pcm_s32le --enable-decoder=pcm_f32le --enable-demuxer=flac --enable-demuxer=wav --enable-protocol=file --enable-protocol=tcp --enable-protocol=udp --enable-protocol=pipe --enable-protocol=fd --enable-muxer=matroska --enable-muxer=mp4 --enable-muxer=ipod --enable-swresample --enable-filter=aresample --enable-filter=aformat --enable-filter=anull --enable-schannel --disable-stripping
  libavutil      60. 20.100 / 60. 20.100
  libavcodec     62. 22.101 / 62. 22.101
  libavformat    62.  6.103 / 62.  6.103
  libavdevice    62.  2.100 / 62.  2.100
  libavfilter    11. 10.101 / 11. 10.101
  libswscale      9.  3.100 /  9.  3.100
  libswresample   6.  2.100 /  6.  2.100
Decoders:
 V..... = Video
 A..... = Audio
 S..... = Subtitle
 .F.... = Frame-level multithreading
 ..S... = Slice-level multithreading
 ...X.. = Codec is experimental
 ....B. = Supports draw_horiz_band
 .....D = Supports direct rendering method 1
 ------
 AF...D flac                 FLAC (Free Lossless Audio Codec)
 A....D pcm_f32le            PCM 32-bit floating point little-endian
 A....D pcm_s16le            PCM signed 16-bit little-endian
 A....D pcm_s32le            PCM signed 32-bit little-endian
```
