---
layout: single
title: "Visual Studio 오프라인 설치본 다운로더 공개"
date: 2026-8-23 22:32:00 +0900
categories:
  - MyProgram
---

## 1. 폐쇄망 환경과 오프라인 설치본이 필요한 이유

대부분의 최신 개발 환경은 웹 인스톨러를 기본으로 사용한다.\
네트워크에서 필요한 구성 요소만 그때그때 받아 설치하는 방식이다.

하지만 보안이 엄격한 망분리 폐쇄망, 방산 환경 등 외부 인터넷 연결이 차단된 PC에서는 웹 인스톨러를 쓸 수 없다.\
네트워크 회선 속도가 느린 환경이나 여러 대의 PC에 동일한 개발 환경을 신속하게 배포해야 할 때도 수십 GB 분량의 패키지를 미리 받아둔 오프라인 레이아웃(Offline Layout)이 필수적이다.

## 2. Visual Studio 오프라인 설치본 다운로드 방법

Microsoft는 Visual Studio를 오프라인 환경에 설치할 수 있도록 공식 커맨드라인 레이아웃 다운로드 기능을 지원한다.

### 지원 버전 및 에디션

* Visual Studio 2019 (v16), 2022 (v17), 2026 (v18)
* Community, Professional, Enterprise 에디션

### 다운로드 절차

1. Microsoft 공식 배포 링크(`aka.ms`)를 통해 대상 버전/에디션의 부트스트래퍼(`vs_professional.exe` 등)를 다운로드
2. 명령 프롬프트(CMD)에서 `--layout`과 `--lang` 옵션을 주어 실행
```bat
vs_professional.exe --layout "D:\VS_Layout\VS2022_Professional" --lang ko-KR en-US
```
3. 부트스트래퍼가 실행되면서 지정한 폴더에 전체 설치 패키지와 오프라인 인스톨러를 로컬 캐시로 내려받음\
언어 코드는 `ko-KR`, `en-US`, `ja-JP` 등 14개 로케일 코드를 지원하며, 공백으로 구분해 복수 지정할 수 있다.

## 3. 폐쇄망 PC에서 설치하기

다운로드가 완료된 레이아웃 폴더 전체를 외장 저장장치로 복사해 폐쇄망 PC로 이동한다.\
오프라인 설치 시 반드시 거쳐야 하는 과정이 있다.

### 1. 루트 인증서 등록
폐쇄망 PC는 인터넷에 연결되어 있지 않아 Microsoft 서명 검증에 실패할 수 있다.\
레이아웃 내 `certificates\` 폴더에 들어 있는 `.cer` 인증서들을 **관리자 권한**으로 로컬 루트 저장소에 먼저 등록해야 한다.

```bat
certutil -addstore -f "Root" "certificates\manifestSignCertificates.cer"
```

### 2. 오프라인 모드로 설치 관리자 실행
레이아웃 루트에 생성된 `vs_setup.exe`를 `--noweb` 옵션과 함께 관리자 권한으로 실행한다.

```bat
vs_setup.exe --noweb
```

이 옵션을 지정해야 웹 접속 시도를 생략하고 로컬에 저장된 패키지만으로 설치를 진행한다.

## 4. 귀찮음을 덜기 위해 만든 GUI 도구

버전별 부트스트래퍼 URL을 찾고, 경로 인자를 조합하고, 인증서 등록 배치 파일까지 매번 수작업으로 만드는 과정은 번거롭다.\
오타로 인해 다운로드가 중간에 꼬이기도 쉽다.

이 과정을 자동화하기 위해 가벼운 MFC 기반의 도구 **“Visual Studio Layout Generator”**를 제작했다.

![image](/images/2026-08-23/VSLayoutGen_B_Q.webp)

* **직관적인 UI 설정:**\
VS 버전, 에디션, 언어, 기본 저장 경로를 콤보박스와 에디트 컨트롤로 손쉽게 지정
* **입력 유효성 검증:**\
ANSI 호환성 검사, 지원 언어 코드 검증을 통해 명령행 인자 오류를 사전에 차단
* **자동 스크립트 생성:**
  * `DownloadLayout.bat`:\
부트스트래퍼가 없으면 `curl`로 자동 다운로드한 뒤 레이아웃 캐시를 구축/갱신.
  * `InstallOffline.bat`:\
관리자 권한 자동 승격(UAC), `certificates\` 내 인증서 일괄 등록, `--noweb` 모드 설치 실행을 한 번에 처리.
* **원클릭 실행 및 중복 방지:**\
UI에서 바로 다운로드를 실행할 수 있으며, 백그라운드 프로세스 핸들을 감지하여 중복 실행을 방지한다.

복잡한 명령어 입력 없이 클릭 몇 번으로 폐쇄망용 설치 스크립트와 레이아웃 준비를 마칠 수 있다.

다운은 아래 링크에서 받을 수 있다.

{% include bnl_download-box.html
   file="/attachment/2026-08-23/VSLayoutGen.rar"
   password="teus.me" %}

덧. Gemini에게 아이콘 제작을 시켰더니 **불사파** 아이콘을 가져왔음…

![image](/images/2026-08-23/download_icon_B_okl_s36_Q.webp)
