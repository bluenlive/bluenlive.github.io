---
layout: single
title: "한동안은 모든 성능을 다 발휘하기 힘들 MainConcept HEVC 인코더"
date: 2026-1-23 21:22:00 +0900
categories:
  - media
---

나는 HEVC 인코더로 [MainConcept의 HEVC 인코더](https://www.mainconcept.com/ffmpeg){:target="_blank"}를 사용한다.\
이 인코더를 몇 년을 사용해오고 있는데, 인코딩 성능이 상당히 만족스럽다.\
**NVidia GPU의 HW와 SW를 병행해서 적용**하여 성능과 품질 두 마리 토끼를 잡은 인코더다.

최근에 그래픽 카드 대란을 뚫고 **RTX 5070Ti**를 구매했다.\
**12GB 이상 메모리가 장착된 그래픽 카드 생산량의 감소**가 예상된 상황에서 기적적인 구매였다.

글카는 여러모로 만족스럽게 사용하고 있는데, HEVC 인코딩에서 문제가 발생했다.\
인코딩이 제대로 되지 않는 것이다.

실행 해보니 아래와 같은 오류를 볼 수 있었다.

```text
Stream mapping:
  Stream #0:0 -> #0:0 (rawvideo (native) -> hevc (omx_enc_hevc))
Trying to load mc_enc_hevc library
Failed to initialize NV_ENC: __lib_enc_hevc_nv__::nv_transfer_helper_c::create : CUDA driver API error CUDA_ERROR_NO_BINARY_FOR_GPU at C:\builds\0\enc_hevc\src\nv_acc\nv_enc\nv_transfer.cpp:32

Creating MainConcept HEVC/H.265 video encoder ...
  Version:  15.2.0.18453
  Platform: Windows 64bit (AVX2 + NVENC HYBRID)
HEVC/H.265 Error. Failed memory allocation operation.
hevcOutVideoNew failed
[omx_enc_hevc @ 000001928F21D300] OMX error 0x8000100a
[omx_enc_hevc @ 000001928F21D300] Component cannot allocate buffers
[vost#0:0/omx_enc_hevc @ 000001928F21AB40] Error while opening encoder - maybe incorrect parameters such as bit_rate, rate, width or height.
[vf#0:0 @ 000001928F21E180] Error sending frames to consumers: Unknown error occurred
[vf#0:0 @ 000001928F21E180] Task finished with error code: -1313558101 (Unknown error occurred)
[vf#0:0 @ 000001928F21E180] Terminating thread with return code -1313558101 (Unknown error occurred)
[vost#0:0/omx_enc_hevc @ 000001928F21AB40] Could not open encoder before EOF
[vost#0:0/omx_enc_hevc @ 000001928F21AB40] Task finished with error code: -22 (Invalid argument)
[vost#0:0/omx_enc_hevc @ 000001928F21AB40] Terminating thread with return code -22 (Invalid argument)
```

이 인코더는 HEVC 인코딩에 네 가지 모드를 제공한다.\
**SW**, **NVENC full**, **NVENC driven**, **NVENC hybrid**.\
앞의 두 개는 SW만 사용하거나, NVENC만 사용하고, 뒤의 둘이 SW와 HW(NVENC)를 혼합해서 사용한다.

이 중 뒤의 두 모드에 대해서 오류가 발생하는 것을 확인했다.\
즉, **드라이버와 통신하여 작업**을 하는 경우에만 **오류가 발생**하는 것이다.

오류 내역을 정리해서 **버그 리포팅**을 했고, 답장을 받았다.

![image](/images/2026-01-23/mc_encoder_B_okl_s64_Q.png){: .align-center}

메일의 골자는 다음과 같다.

{: .bluebox-blue}

- 플러그인 핵심 라이브러리가 오래된 Nvidia SDK로 컴파일됨  
- 해당 SDK는 RTX 50xx 시리즈를 지원하지 않음  
- RTX 4070 등 이전 GPU에서는 정상 동작  
- RTX 50xx에서는 NVENC 모드가 실패함  
- 새 엔진은 준비되어 있으나 라이선스 보호 구조로 교체 불가  

환불도 가능하다는 얘기도 있었지만, 그럴 생각은 없다.\
**어떻게든 개발자들은 답을 찾을 것**이니까.

여튼 한동안은 모든 성능을 다 발휘할 수는 없는 상태다.\
**SW Only** 모드로 실행할 수 밖에 없을 듯.
