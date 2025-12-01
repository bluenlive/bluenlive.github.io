---
layout: single
title: "간단히 만들어본 도로명 주소 검색 앱"
date: 2024-10-06 23:34:00 +0900
categories:
  - MyProgram
---

[이전 포스팅](/algorithm/road_addr_csharp/)을 쓰면서 간단히 예제 삼아 만들어본 **도로명 주소 검색 앱**을 소개한다.

이 앱에는 API 키가 포함되어 있지 않으며, 사용자가 직접 키를 발급받아야 한다.  
[국가주소정보시스템 API신청하기](https://business.juso.go.kr/addrlink/openApi/apiReqst.do){:target="_blank"}에 접속해서 **검색API**로 발급받으면 된다.

![image](/images/2024-09-05/apis64_Q.png){: .align-center}
*검색API*

이 프로그램을 처음 실행하면 아래와 같이 API 키를 입력하라는 창이 뜬다.  
여기에 발급받은 API 키를 입력하면 된다.

![image](/images/2024-09-07/apikey_B_Q.png){: .align-center}

이 키는 레지스트리에 암호화되어 저장되며, 다음 실행부터는 이 키를 사용한다.  
혹시 잘못된 키를 입력했을 경우는 **시스템 메뉴**에서 **API 키를 변경**하는 메뉴를 찾을 수 있다.

실행 화면은 아래와 같다.  

![image](/images/2024-09-07/roadaddr_B_Q.png){: .align-center}

돋보기 모양의 검색 버튼을 클릭해도 되지만, 간단하게 엔터키를 눌러도 된다.  
검색 결과를 클릭하면 화면 아래쪽에 영문 주소를 포함한 항목들이 나타난다.  
각 항목들 앞의 **제목을 클릭**하면 **클립보드에 복사**되니 편리하게 사용할 수 있다.

아래 링크에서 다운받을 수 있다.

{% include bluenlive/download-box.html
   file="/attachment/2024-09-07/RoadAddress.rar"
   password="teus.me" %}

## 히스토리

{: .bluebox-history}
- 2024.9.7꞉ 1.00 공개
  - 최초 공개

- 2024.9.8꞉ 1.01 공개
  - Ctrl+F1로 API Key 변경 메뉴 추가

- 2024.9.14꞉ 1.02 공개
  - 컬럼 헤더 클릭으로 정렬 기능 추가
  - 검색 후 컬럼 폭 자동으로 다시 맞춤

- 2024.9.21꞉ 1.03 공개
  - API 키를 가끔 제대로 저장하지 못하던 문제 수정
  - HiDPI를 제대로 지원하도록 수정
  - 컬럼 폭 자동으로 맞추는 기능을 개선

- 2024.10.6꞉ 1.04 공개
  - 정규식 마이너 수정
