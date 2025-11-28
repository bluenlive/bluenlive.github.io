---
layout: single
title: "CodeMeter 서비스가 왜 죽지?"
date: 2025-3-30 01:28:00 +0900
categories:
  - media
---

[MainConcept의 HEVC 인코더](https://www.mainconcept.com/ffmpeg){:target="_blank"}는 **불법 복제 방지 솔루션**으로 **CodeMeter**를 사용한다.\
이 인코더를 몇 년을 사용해왔는데, 인코딩 성능이 여전히 훌륭하다.

그런데, 얼마 전부터 **CodeMeter 서비스**가 중단되어 인코딩이 진행되지 않는 현상이 종종 발생했다.

![image](/images/2025-03-30/CodeMeterIcon.png){: .align-center}
*서비스가 다운되면 흑백으로 표시되는 트레이 아이콘*

일반적으로는 이 서비스를 다시 시작하려면 트레이 아이콘을 클릭해서 서비스를 다시 시작하면 된다.

![image](/images/2025-03-30/CodeMeter_CS_B_Q.png){: .align-center}
*정상적으로 실행될 때의 서비스 화면*

이 작업을 한두번 할 때야 모르겠지만, 매번 반복되니 다시 시작하는 것도 귀찮다...

이를 좀 더 손쉽게 하려면 윈도우 서비스 관리자에서 설정을 조금만 손대면 된다.\
일단 서비스의 등록 여부는 아래처럼 확인할 수 있다.

![image](/images/2025-03-30/Services_Bs64_Q.png){: .align-center}

여기서 **CodeMeter Runtime Server**를 찾아 아래와 같이 설정한다.\
간단히 설명해서 서비스가 실패하면 1분 후에 다시 실행하도록 설정하는 것이다.

![image](/images/2025-03-30/CodeMeterService_Bs64_Q.png){: .align-center}

단지 이것만으로 서비스가 항상 잘 동작되는 것을 확인할 수 있다.\
지화자!
