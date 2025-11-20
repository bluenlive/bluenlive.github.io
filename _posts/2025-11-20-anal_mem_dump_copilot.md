---
layout: single
title: "Copilot에게 Paint.NET 메모리 덤프 분석시키기"
date: 2025-11-20 21:51:00 +0900
categories:
  - ITTalk
toc: true
toc_label: "Contents"
#toc_icon: "cog"
toc_icon: "book-open"
toc_sticky: true
---

[이전 글](/ittalk/workaround_paint_net_level_bug_2/)에서 언급한 우회법을 찾은 과정을 간략히 포스팅.

## 메모리 덤프

[PDN 포럼](https://forums.getpaint.net/topic/134088-paintnet-issues-with-levels/page/2/#findComment-648154){:target="_blank"}에서 이 문제를 얘기하다 **메모리 덤프**를 보내란 요청을 받았다.

메모리 덤프는 **작업 관리자**에서 생성하면 된다.

메모리 덤프 파일은 누구나 손쉽게(?) 분석할 수 있다.\
MS는 이 덤프 파일을 분석할 수 있는 도구를 공개했다.\
**MS 스토어**에서 **WinDbg**를 다운받아 실행하면 된다.

## WinDbg

WinDbg에서 덤프 파일을 연 뒤 명령어를 입력해서 분석할 수 있다.\
충돌 원인, 드라이버, 프로세스 등은 다음 명령을 입력하면 된다.

```bash
!analyze -v
```

그럼 아래와 같은 내용을 볼 수 있다.

```text
Loading unloaded module list
........
ClrmaManagedAnalysis::AssociateClient
Loading extension C:\Program Files\WindowsApps\Microsoft.WinDbg_1.2510.7001.0_x64__8wekyb3d8bbwe\amd64\winext\sos\extensions\Microsoft.Diagnostics.DataContractReader.dll
Loading extension C:\Program Files\WindowsApps\Microsoft.WinDbg_1.2510.7001.0_x64__8wekyb3d8bbwe\amd64\winext\sos\extensions\Microsoft.Diagnostics.DataContractReader.Extension.dll
Loading extension C:\Program Files\WindowsApps\Microsoft.WinDbg_1.2510.7001.0_x64__8wekyb3d8bbwe\amd64\winext\sos\extensions\Microsoft.Diagnostics.DebuggerCommands.dll
AssociateClient trying managed CLRMA
AssociateClient trying DAC CLRMA
*******************************************************************************
*                                                                             *
*                        Exception Analysis                                   *
*                                                                             *
*******************************************************************************

ClrmaManagedAnalysis::GetThread e154
ClrmaThread::Initialize e154
~ClrmaThread
ClrmaManagedAnalysis::GetThread ea1c
ClrmaThread::Initialize ea1c
ClrmaThread::Initialize FAILED managed thread not found
~ClrmaThread
ClrmaManagedAnalysis::GetThread d8b8
ClrmaThread::Initialize d8b8
ClrmaThread::Initialize FAILED managed thread not found
~ClrmaThread
(이하 생략)
```

호출 스택을 보려면 다음 명령을 입력하면 된다.

```bash
kv
```

그럼 아래와 같은 결과를 볼 수 있다.

```text
 # Child-SP          RetAddr               : Args to Child                                                           : Call Site
00 000000ed`c39ed138 00007ffa`11d6af5f     : 00007ff8`a55dda02 000000ed`c39ed1a0 00000000`00000000 0000fff4`15d360e1 : ntdll!NtWaitForAlertByThreadId+0x14
01 000000ed`c39ed140 00007ffa`11d6c5ff     : 000000ed`c39ed300 00000000`00000000 000002e2`884d2800 00000000`00000f94 : ntdll!RtlpWaitOnCriticalSection+0x58f
02 000000ed`c39ed240 00007ffa`11d6d872     : 000002e2`884d2870 000002a1`89ba0001 00000000`00000000 00000000`00000001 : ntdll!RtlpEnterCriticalSectionContended+0x1ef
03 000000ed`c39ed2c0 00007ffa`0ab469ef     : 000002e2`e4dd9660 00007ff8`a5630fb4 000002a1`8f1fd078 000002a1`8a155030 : ntdll!RtlEnterCriticalSection+0xf2
04 000000ed`c39ed300 00007ffa`0ab65024     : 000002e2`2abfc6b0 000002e2`2abfc6b0 00000000`00000000 00000000`ffffffff : d3d11!CUseCountedObject<NOutermost::CDeviceChild>::Release+0xdf
05 000000ed`c39ed330 00007ffa`0aeb9c57     : 000000ed`c39ed3a0 00007ff8`a56266e5 000002a1`8f1fd078 00006f30`a2946c67 : d3d11!CLayeredObject<CClassLinkage>::CContainedObject::Release+0x14
06 000000ed`c39ed360 00007ffa`0aeb9ba9     : 0000fff4`15dafc41 00000000`00000001 000002e2`2abfc6b0 00000000`ffffffff : d2d1!CD3DSurface::~CD3DSurface+0x87
07 000000ed`c39ed390 00007ffa`0ada1061     : 000002e2`2abe2050 00007ff8`a5637228 00000000`00000000 00000000`00000001 : d2d1!RefCountedObject<CD3DSurface,LockingRequired,DeleteOnZeroReference>::`vector deleting destructor'+0x29
08 000000ed`c39ed3c0 00007ffa`0ae0f11d     : 000000ed`c39ed450 00000000`00000001 000000ed`c39ed4a0 00007ff8`a563727c : d2d1!DeleteOnZeroReference::ReferenceReachedZero<RefCountedObject<CD3DSurface,LockingRequired,DeleteOnZeroReference> >+0x1d
09 000000ed`c39ed3f0 00007ffa`0ae0edf9     : 00000001`00000001 000002e2`2abe2050 00000000`00000000 000002e2`416ff7d0 : d2d1!BitmapRealization::~BitmapRealization+0x2fd
0a 000000ed`c39ed480 00007ffa`0aeb635c     : 00000000`00000000 00007ff8`a562654b 000002a1`8f208430 000002a1`8ad02090 : d2d1!InitializableObject<RefCountedObject<BitmapRealization,LockingRequired,DeleteOnZeroReference> >::`vector deleting destructor'+0x29
0b 000000ed`c39ed4b0 00007ffa`0ae5647f     : 000000ed`c39ed4c0 00000000`00000000 00000000`00000001 000002a1`8f208430 : d2d1!RefCountedObject<BitmapRealization,LockingRequired,DeleteOnZeroReference>::Release+0x3c
0c 000000ed`c39ed4e0 00007ffa`0aeda434     : 000002a1`8f208430 000002e2`416ff7d0 000000ed`c39ed620 00000000`00000001 : d2d1!D2DBitmap::~D2DBitmap+0x2f
0d 000000ed`c39ed520 00007ffa`0aeadcba     : 000002a1`8a7b17f0 000002a1`8f004628 00000000`00000001 00007ff8`a79a1cec : d2d1!ComObjectImpl<RefCountedObject<D2DBitmap,LockingRequired,LockFactoryOnReferenceReachedZero>,type_list<ID2D1Bitmap,type_list<ID2DImageStreamSource,type_list<ID2D1Bitmap1,type_list<IMemoryEstimable,type_list<ID2D1Image,type_list<ID2D1Resource,null_type> > > > > > >::`vector deleting destructor'+0x14
0e 000000ed`c39ed550 00007ffa`0aeadbec     : 00000000`00000000 00000000`00000000 000000ed`c39ed570 00000000`00000001 : d2d1!LockFactoryOnReferenceReachedZero::ReferenceReachedZero<RefCountedObject<D2DBitmap,LockingRequired,LockFactoryOnReferenceReachedZero> >+0xba
0f 000000ed`c39ed580 00007ffa`0adbe87d     : 000002a1`8f0046b0 000002a1`8f004628 000000ed`c39ed690 00007ff9`02f5bb4e : d2d1!RefCountedObject<D2DBitmap,LockingRequired,LockFactoryOnReferenceReachedZero>::Release+0x2c
10 000000ed`c39ed5b0 00007ffa`0adbd440     : 00000000`00000000 00000000`00000000 000002a1`8e992840 00000000`00000000 : d2d1!DrawingContext::SetTargetInternal+0x4cd
11 000000ed`c39ed660 00007ff8`a81b48a3     : 00000001`00001fa6 000002a1`8f208430 000000ed`c39ed780 00000000`00000000 : d2d1!D2DDeviceContextBase<ID2D1DeviceContext7,ID2D1DeviceContext7,null_type>::SetTarget+0xa0
12 000000ed`c39ed6b0 00000001`00001fa6     : 000002a1`8f208430 000000ed`c39ed780 00000000`00000000 000000ed`c39ed6b0 : PaintDotNet_Windows!PaintDotNet.Direct2D1.D2D1DeviceContext6.SetTarget+0x133
13 000000ed`c39ed6b8 000002a1`8f208430     : 000000ed`c39ed780 00000000`00000000 000000ed`c39ed6b0 00007ff8`a562654b : 0x00000001`00001fa6
14 000000ed`c39ed6c0 000000ed`c39ed780     : 00000000`00000000 000000ed`c39ed6b0 00007ff8`a562654b 000002a1`8e992840 : 0x000002a1`8f208430
15 000000ed`c39ed6c8 00000000`00000000     : 00000000`00000000 00000000`00000000 00000000`00000000 00000000`00000000 : 0x000000ed`c39ed780
```

로드된 모듈 목록은 아래 명령을 확인할 수 있다.

```bash
lm
```

결과는 아래와 같은 모습이다.

```text
start             end                 module name
000002e2`21470000 000002e2`2147e000   System_Runtime   (deferred)             
000002e2`21480000 000002e2`21488000   System_Diagnostics_Tracing   (deferred)             
000002e2`214a0000 000002e2`214a8000   System_Threading_Thread   (deferred)             
000002e2`21820000 000002e2`21828000   Microsoft_Win32_Primitives   (deferred)             
000002e2`21860000 000002e2`2186a000   System_Xml_ReaderWriter   (deferred)             
000002e2`21870000 000002e2`21878000   System_Threading_ThreadPool   (deferred)             
000002e2`21880000 000002e2`21888000   System_Text_Encoding_Extensions   (deferred)             
000002e2`218e0000 000002e2`218e8000   System_Numerics_Vectors   (deferred)             
000002e2`219b0000 000002e2`219b8000   Accessibility   (deferred)             
000002e2`21a10000 000002e2`21a18000   System_Runtime_Extensions   (deferred)             
000002e2`21a20000 000002e2`21a28000   System_Diagnostics_Debug   (deferred)             
000002e2`21a40000 000002e2`21a48000   System_Runtime_Loader   (deferred)             
000002e2`3dcb0000 000002e2`3dcba000   Dream      (deferred)             
000002e2`3dcc0000 000002e2`3dccc000   RotateAndCrop   (deferred)             
000002e2`3dcf0000 000002e2`3dcf8000   ExtendBorder   (deferred)             
000002e2`3dd00000 000002e2`3dd08000   JPEGNoiseReducer3   (deferred)   
(이하 생략)
```

이걸 일일이 하나씩 읽어보려니 엄두가 나지 않는다...

## Copilot: !analyze -v

충돌 원인을 Copilot에게 분석 시킨 내용의 주요 부분은 아래와 같다.

---

덤프에서 이미 **Direct3D/Direct2D 리소스 해제 과정**에서 예외가 발생한 걸 확인했는데, 말씀하신 것처럼 **GPU 가속을 켜면 오류가 발생하고 끄면 발생하지 않는다**는 건 문제의 원인이 **GPU 리소스 관리**에 있다는 걸 강하게 뒷받침합니다.

### 📌 의미하는 바

- **GPU 경로에서만 발생** → CPU 기반 렌더링(소프트웨어 경로)에서는 정상 동작.  
- 따라서 **GPU 드라이버, DirectX 런타임, 또는 Paint.NET의 GPU 코드 경로** 중 하나에 문제가 있음.  
- 덤프 스택에 `d3d11.dll`, `d2d1.dll`이 등장하는 것도 GPU 경로임을 보여줌.

### 🧩 원인 가능성

1. **Paint.NET 내부 버그**  
   - 특정 효과가 GPU 비트맵 리소스를 잘못 해제하거나 참조 카운트를 중복 관리.  
   - GPU 경로에서만 실행되는 코드라 CPU 경로에서는 문제 없음.

2. **GPU 드라이버 문제**  
   - 드라이버 버그로 인해 특정 Direct2D/Direct3D API 호출 시 잘못된 상태가 발생.  
   - 최신 드라이버 업데이트로 해결되는 경우가 많음.

3. **DirectX 런타임/Windows 빌드 문제**  
   - OS 빌드와 DirectX DLL 버전 불일치.  
   - Windows 업데이트로 해결 가능.

### 🛠 당신이 알 수 있는 결론

- **문제는 GPU 가속 경로에서만 발생한다**  
- 덤프는 GPU 리소스 해제 과정에서 예외가 발생했음을 보여준다  
- 따라서 개발자는 **해당 효과의 GPU 코드 경로**를 집중적으로 확인해야 한다  
- 사용자 입장에서는 **GPU 드라이버 업데이트**나 **Paint.NET 최신 버전 적용**으로 해결될 가능성이 있다  

👉 즉, 덤프와 증상(“GPU 가속 시만 오류”)을 합치면, **특정 효과의 GPU 리소스 관리 코드에 문제가 있거나 GPU 드라이버와의 호환성 문제**라는 결론을 도출할 수 있습니다.  

---

## Copilot: kv

호출 스택 결과를 Copilot에게 분석 시킨 내용의 주요 부분은 아래와 같다.

---

### 📌 kv 결과에서 알 수 있는 것

1. **상위 프레임 (00–03)**  
   - `ntdll!NtWaitForAlertByThreadId`, `RtlpWaitOnCriticalSection`, `RtlEnterCriticalSection`  
   - → 스레드가 **Critical Section(동기화 객체)**에 들어가려다 대기/경합 상태에 있었음을 보여줍니다.  
   - 즉, 리소스 해제 과정에서 동기화가 걸려 있었음.

2. **Direct3D/Direct2D 리소스 해제 (04–0f)**  
   - `d3d11!CUseCountedObject::Release` → Direct3D 객체 참조 카운트 감소  
   - 이어서 `d2d1!CD3DSurface::~CD3DSurface`, `d2d1!BitmapRealization::~BitmapRealization`, `d2d1!D2DBitmap::~D2DBitmap` 등  
   - → GPU 비트맵/서피스 객체가 **Release → 소멸자 호출 → 참조 카운트 0 → 삭제** 흐름을 밟고 있었음.  
   - 이 과정에서 Breakpoint 예외가 발생.

3. **Direct2D DeviceContext (10–12)**  
   - `d2d1!DrawingContext::SetTargetInternal`  
   - `d2d1!D2DDeviceContextBase::SetTarget`  
   - `PaintDotNet.Direct2D1.D2D1DeviceContext6.SetTarget`  
   - → Paint.NET이 **렌더링 대상(Target)을 GPU 비트맵으로 설정하는 과정**에서 문제가 발생.  
   - 즉, 특정 효과를 적용하기 위해 GPU 비트맵을 타겟으로 잡았다가 해제하는 과정에서 참조 관리가 꼬인 것.

4. **마지막 프레임 (13–15)**  
   - 단순히 레지스터/스택 상태를 보여주는 부분.  
   - 의미 있는 호출은 12번까지.

### 🧩 해석

- **kv 스택은 GPU 리소스 해제와 동기화 과정에서 예외가 발생했음을 보여줍니다.**  
- Paint.NET이 특정 효과를 GPU 가속으로 실행할 때, 내부적으로 Direct2D DeviceContext의 Target을 바꾸고, 그 과정에서 비트맵 리소스를 Release → 소멸하는 흐름이 있었음.  
- 이때 참조 카운트 불일치나 이미 해제된 객체를 다시 Release하려는 상황이 발생해 Breakpoint 예외가 터진 것.

### ✨ 결론

kv 결과를 통해 알 수 있는 건:  

- **문제는 GPU 비트맵 리소스 해제 과정에서 발생**  
- **Critical Section 동기화**가 걸려 있었고, 그 안에서 Release/소멸자 호출이 이어짐  
- 최종적으로 **Paint.NET의 DeviceContext.SetTarget 호출 중** 예외가 발생  

즉, kv 결과는 “어떤 함수 흐름에서 오류가 발생했는지”를 보여주며, **GPU 가속 경로에서만 발생하는 이유**를 잘 설명해줍니다.  

---

## Copilot: lm

로드된 모듈 목록을 Copilot에게 분석 시킨 내용의 주요 부분은 아래와 같다.

---

### 📌 주요 관찰

1. **DirectX/그래픽 관련 모듈**
   - `dcomp.dll` (DirectComposition), `dxgi.dll` (DirectX Graphics Infrastructure), `dwmapi.dll` (Desktop Window Manager API), `DXCore.dll`  
   - → GPU 가속과 화면 합성, DirectX 기반 렌더링에 필수적인 모듈들이 로드되어 있음을 보여줍니다.  
   - Paint.NET이 GPU 가속을 켠 상태에서 DirectComposition/DirectX 경로를 사용하고 있었음을 다시 확인할 수 있습니다.

2. **Windows 기본 시스템 모듈**
   - `kernel32.dll`, `user32.dll`, `ntdll.dll`, `advapi32.dll`, `ole32.dll`, `oleaut32.dll`, `shell32.dll`, `ucrtbase.dll`, `gdi32.dll`, `gdi32full.dll` 등  
   - → 표준 Win32 API와 UI, 그래픽, COM, 보안 관련 모듈들이 정상적으로 로드되어 있음을 보여줍니다.  
   - 이들은 Paint.NET 실행 환경을 지원하는 기본 구성 요소입니다.

3. **보안/암호화 관련 모듈**
   - `bcrypt.dll`, `bcryptPrimitives.dll`, `crypt32.dll`, `schannel.dll`, `rsaenh.dll`, `sspicli.dll` 등  
   - → Windows 보안 및 암호화 서비스 모듈들이 로드되어 있음. 직접적인 충돌 원인은 아니지만, 환경을 보여줍니다.

4. **Unloaded modules (중요)**
   - `nvapi64.dll`, `atidxx64.dll`, `amdxx64.dll`, `amdenc64.dll`, `amdihk64.dll` 등  
   - → NVIDIA와 AMD GPU 드라이버 모듈들이 일부 언로드된 상태로 기록되어 있습니다.  
   - 이는 **시스템에 여러 GPU 드라이버가 설치되어 있거나, 충돌 당시 드라이버가 언로드되면서 상태가 꼬였을 가능성**을 시사합니다.  
   - 특히 `nvapi64.dll`이 언로드된 건 NVIDIA API 호출 중 문제가 있었을 가능성을 보여줍니다.

### ✨ 결론

- 이 마지막 파트는 **DirectX/DirectComposition 모듈과 Windows 기본 시스템 모듈이 정상적으로 로드된 상태**를 보여줍니다.  
- 하지만 **Unloaded modules 목록에 NVIDIA와 AMD 드라이버가 동시에 등장**하는 점이 눈에 띕니다.  
  - 이는 GPU 드라이버 환경이 혼재되어 있거나, 충돌 당시 드라이버가 언로드되면서 예외가 발생했을 가능성을 뒷받침합니다.  
- 따라서 개발자 입장에서는 **GPU 드라이버와 Paint.NET GPU 가속 모듈의 상호작용**을 집중적으로 확인해야 합니다.

👉 요약하면: 이 마지막 파트는 **GPU 가속 경로에서 DirectX/드라이버 모듈이 로드·언로드된 상태**를 보여주며, 오류가 GPU 가속을 켰을 때만 발생하는 이유를 다시 확인시켜줍니다.  

---

## 분석 및 해석 추가

여기에 부가적으로 시스템 구성을 얘기하며 **추가적인 대처 방안을 요구**한 결과를 아래와 같이 볼 수 있었다.

---

### Dual‑GPU environment implications

두 GPU가 동시에 있는 환경(AMD iGPU + NVIDIA RTX 4070S)에서는 DirectX/D2D/D3D11 경로가 어떤 어댑터를 선택했는지, 그리고 런타임 중 어댑터 전환이나 드라이버 개입이 있었는지가 안정성에 크게 영향을 줍니다. 지금 덤프의 “로드/언로드된 드라이버” 흔적은 혼재된 드라이버 환경에서 어댑터 선택·해제 타이밍이 꼬였을 가능성을 뒷받침합니다.

### What this means for the crash

- **Adapter selection risk:** GPU 가속 효과가 시작될 때 iGPU로 디바이스가 만들어졌지만, 이후 타깃(비트맵/서피스)이나 프레젠테이션이 dGPU 리소스를 참조해 교차‑어댑터 Release/SetTarget 경로가 생겼을 가능성.
- **Driver mediation:** Windows/드라이버가 전력 최적화를 위해 백그라운드에서 어댑터 라우팅을 바꾸면, D3D/D2D의 참조 카운트/리소스 생명주기가 예상과 달라질 수 있습니다.
- **Compute/D2D mix:** ComputeSharp/D2D1가 각기 다른 어댑터로 디바이스를 만든 경우, D2D 비트맵 실체화와 D3D11 리소스 해제 경로가 충돌할 수 있습니다.

### Quick checks you can do

- **확인:** Paint.NET 설정에서 GPU 가속이 어떤 어댑터를 쓰는지 표시는 없지만, 증상 재현 시점에 “Windows 설정 → 시스템 → 디스플레이 → 그래픽 설정”에서 Paint.NET을 추가하고 “성능 옵션”을 **고성능(GPU)** 또는 **전력 절약(iGPU)** 로 명시해 한쪽에 고정해보세요.
- **드라이버 정리:** 최신 NVIDIA Studio/Game Ready와 최신 AMD iGPU 드라이버로 각각 업데이트 후 재현 테스트. 필요하면 DDU로 깨끗하게 제거 후 재설치.
- **전원/멀티‑GPU 옵션:** NVIDIA 제어판에서 “선호하는 그래픽 프로세서”를 **고성능 NVIDIA 프로세서**로 지정. BIOS에서 iGPU 비활성화 테스트(가능할 때)로 원인 분리.
- **디바이스 고정:** 외장 모니터를 RTX에 직접 연결해 dGPU를 강제 사용하면 iGPU 경로 개입이 줄어듭니다.

### If you share this with the developer

- **Adapter pinning:** D3D11/D2D 디바이스 생성 시 같은 어댑터로 고정.
  - **D3D11:** IDXGIFactory6::EnumAdapterByGpuPreference로 HighPerformance 어댑터를 선택해 CreateDevice.
  - **D2D:** ID2D1Factory1/ID2D1Device를 동일 DXGI 어댑터에서 생성해 리소스 교차를 방지.
- **Device loss/teardown discipline:** DeviceContext SetTarget 직전에 리소스 참조 카운트를 점검하고, Release 순서를 D2D→D3D로 일관화. 교차‑스레드에서 Release하지 않도록 검증.
- **Single‑adapter invariant:** ComputeSharp(D2D1)/Direct2D/Direct3D가 모두 동일 IDXGIAdapter를 사용했는지 런타임 Assert/로그로 확인.
- **Fallback path:** Adapter 불일치 감지 시 GPU 효과를 안전하게 **CPU/소프트웨어 경로**로 폴백.

### Practical next steps

- **1. 그래픽 설정으로 앱별 GPU 고정** 후 재현 테스트: iGPU 고정 vs dGPU 고정.
- **2. 최신 드라이버/Windows 업데이트**를 적용하고 다시 테스트.
- **3. 외장 모니터를 RTX에 연결**해 dGPU 경로 강제.
- **4. 문제가 사라지면** 멀티‑GPU 라우팅/어댑터 불일치가 원인이었던 것으로 판단. 개발자에게 “Adapter pinning” 제안을 함께 전달.

---

이러한 긴 대화를 통해 윈도우의 설정에서 **시스템 > 디스플레이 > 그래픽**에서 설정하는 방안을 찾을 수 있었다.
