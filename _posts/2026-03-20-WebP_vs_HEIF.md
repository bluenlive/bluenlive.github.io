---
layout: single
title: "WebP 및 HEIF 압축률/화질 간단 테스트 결과"
date: 2026-3-20 22:29:00 +0900
categories:
  - media
---

그동안 블로그 이미지에 꾸역꾸역 [mozjpeg](https://github.com/mozilla/mozjpeg/)와 [pngquant](https://pngquant.org/)를 적용해왔다.\
[WebP](https://en.wikipedia.org/wiki/WebP)나 [AVIF](https://en.wikipedia.org/wiki/AVIF)가 좋은 걸 모르는 바는 아니지만, 브라우저 호환성을 **핑계**로 버텨왔었다.

하지만, 이제 그만 해야겠다는 생각이 들어 **WebP**로 넘어가기로 했다.\
넘어가는 김에 사진을 WebP 및 HEIF로 인코딩 해서 **용량 대비 품질**을 비교해보기로 했다.

비교 방법은 사진 여러장을 같은 기준으로 인코딩 한 뒤 [PSNR-HVS-M](https://ponomarenko.info/psnrhvsm.htm)[^1]과 [SSIM](https://tiabet.tistory.com/entry/SSIM-%EC%9D%B4%EB%AF%B8%EC%A7%80-%ED%92%88%EC%A7%88-%ED%8F%89%EA%B0%80-%EC%A7%80%ED%91%9C-%EC%A0%95%EB%A6%AC)[^2]을 계산해서 용량 대비 품질을 정량적으로 비교하는 것.

WebP는 물론 [구글에서 공개한 라이브러리](https://github.com/webmproject/libwebp)를 사용하면 되고, HEIF는 WIC를 이용한 인코딩과 [libheif](https://github.com/strukturag/libheif)+[x265](https://x265.readthedocs.io/en/master/)를 모두 적용해봤다.

그런데, 오픈 소스 쪽(x265)은 결과가 놀라웠다.\
WIC-HEIF에 비해 **PSNR-HVS-M**이 심각하게 낮다.\
참고로, 모든 그래프의 **가로축은 원본(jpeg) 대비 압축률**이다.

![image](/images/2026-03-20/compare1_okl_s64_Q.webp)
*뭘 해도 20dB 부근에서 헤매는 x265 진영, 이 값은 33dB를 하한선으로 보는 게 일반적임*

**SSIM** 역시도 마찬가지로 심각하게 낮다.\
이 정도면 **오픈 소스를 활용한 HEIF 압축은 포기**하는 것이 좋다.
더군다나 x265 쪽은 **라이선스 문제**까지 엮여있어 프로그램을 배포하는 것도 주의가 필요하다.

![image](/images/2026-03-20/compare2_okl_s64_Q.webp)
*x265 진영은 유사도 역시 0.84 정도에서 헤매고 있음*

---

결국 WebP와 WIC-SSIM을 비교하는 것 외엔 유의미한 비교 대상이 없다.

**PSNR-HVS-M**의 결과는 기대와 달랐다.\
내 예상은 HEIF 쪽이 품질이 더 높게 나오는 것이었는데, WebP가 더 높게 나왔다.\
물론 33dB를 다 넘는 값들이라 눈에 띄는 정도는 아니다.

![image](/images/2026-03-20/compare3_okl_s64_Q.webp)
*이게 높다는 것은 고주파 영역 디테일에 WebP가 더 강하다는 뜻*

**SSIM**은 용량 대비 차이가 거의 없다.

![image](/images/2026-03-20/compare4_okl_s64_Q.webp)

결론적으로 WebP와 HEIF(WIC)는 구조적인 면에서 용량 대비 차이는 거의 없으며, 세부 디테일은 WebP가 좀 높다는 것.\
그리고, **WebP**로 압축할 때 품질(fidelity)는 **88이** 용량이 작으면서도 품질이 훌륭한 **sweet spot**이라는 결론.

[^1]: Peak Signal-to-Noise Ratio with HVS and Masking, PSNR에 인간 시각 특성(HVS)을 반영한 지표. 단위는 dB.
[^2]: Structural Similarity Index Measure, 이미지의 구조적 정보(휘도, 대비, 구조)가 얼마나 보존되었는가를 측정하는 지표.
