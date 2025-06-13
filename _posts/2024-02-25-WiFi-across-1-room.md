---
layout: single
#classes: wide
title: "벽 2개를 가로지르는 Wi-Fi 연결 테스트"
categories:
  - ITTalk
toc: true
toc_label: "Contents"
#toc_icon: "cog"
toc_icon: "book-open"
toc_sticky: true
---

Wi-Fi는 **방 하나를 가로질러 연결**될 수 있을까?  
즉, **콘크리트 벽 2개를 가로지르는 Wi-Fi 연결**이 가능할까?

## Wi-Fi가 벽 두 개를 통과?

전파를 전공한 친구랑 Wi-Fi가 연결 문제를 토의했는데, 재미있는(?) 얘기가 나왔다.  
Wi-Fi가 내 생각만큼 **쉽게 차단될 리가 없다**는 얘기였다.  
내 경험으로는 **손쉽게 차단**되기 때문에 **mesh**도 쓰고 난리도 아니었는데...

**전문가**의 견해로는 설령 방을 건너더라도 마찬가지란 거다.  
그 사이에 **철판**처럼 전파를 차단하는 장애물이 없다면 방 하나 가로지르는 건 간단한 일이라는 것.  
즉, **콘크리트 벽 2개** 쯤은 2.4GHz Wi-Fi가 가로지르는 건 쉬운 일이라는 얘기였다.

마침 남는 TP-Link AC1750에 dd-wrt를 깔아둔 게 있어서 테스트를 해보기로 했다.

![image](</images/2024-02-25b/AC1750s64.jpg>){: .align-center}
*언제나 하나쯤 남아있는 공유기*

게다가, 마침 친구 숙소의 옆옆방에 다른 친구가 있어 그 친구의 공유기를 통해 테스트 할 수 있었다.

![image](</images/2024-02-25b/letsdoit.jpg>){: .align-center}
*기다렸다는 듯이 옆옆방을 친구가 쓰고 있었음*

## 실험 설정

옆옆방 친구(이하 M)의 공유기에 직접 PC를 연결하는 건 실패했다.  
여기에 대한 내 생각은 콘크리트 벽 2개를 **전파가 가로지르지 못하기 때문**이라는 것.  
하지만, Oh는 **철판 등으로 인해 전파가 차단**되었을 뿐, 위치만 잘 잡으면 될 거라는 얘기였다.

![image](</images/2024-02-25b/rooms_Bs64_Q.png>){: .align-center}

Oh의 말이 맞다면 M의 공유기와 추가 공유기를 잘만 배치하면 Wi-Fi가 연결될 거라는 얘기...  
추가 공유기를 Bridge 모드로 설정하면 되는지 여부를 확인할 수 있다.

일단 추가 공유기를 **Client Bridge** 모드로 설정했다.

![image](</images/2024-02-25b/image2_Q.png>){: .align-center}

다음은 Wireless / Basic Settings 설정.

![image](</images/2024-02-25b/image3_Q.png>){: .align-center}

새로 사용할 SSID를 적절히 지정한다.

![image](</images/2024-02-25b/image4_Q.png>){: .align-center}

그리고는 M의 공유기와 연결할 수 있도록 정보를 입력한다.  
참고로, subnet mask는 M의 공유기와 동일하게 입력하고, Gateway는 M의 공유기의 IP를 입력한다.  
아래 화면의 **24**는 **255.255.255.0과 동일**한 의미이다.

![image](</images/2024-02-25b/image5s64_Q.png>){: .align-center}

다음은 Wireless / Wireless Security 설정.  
역시 M의 공유기와 동일한 설정을 해야 한다.

![image](</images/2024-02-25b/image7_Q.png>){: .align-center}

같은 탭에서 새로 사용하는 SSID 쪽의 설정도 확인한다.  
M의 공유기와 동일하게 설정하는 것이 여러모로 편하다.

![image](</images/2024-02-25b/image8_Q.png>){: .align-center}

마지막으로 Setup / Advanced Routing 설정.  
operating Mode를 Router로 설정한다.

여기까지 하고 **Apply Settings**를 누르면 설정된다.  

![image](</images/2024-02-25b/image9_Q.png>){: .align-center}

팁 하나. Status / Wireless 탭에서 **Site Survey**를 누르면 주변 Wi-Fi를 확인할 수 있다.

![image](</images/2024-02-25b/image11_Q.png>){: .align-center}

## 실험 결과

된다. 그것도 **꽤 잘 된다**.  
역시 전문가의 말을 들어야 하는 거구만.

<div style="position: relative; display: inline-block; padding: 15px 45px 15px 15px; margin: 5px 0; border: 1px solid #f8f861; border-left: 30px solid #f8f861; border-bottom-right-radius: 60px 10px; word-break: break-all; background: #ffff88; background: -moz-linear-gradient(-45deg, #ffff88 81%, #ffff88 82%, #ffff88 82%, #ffffc6 100%); background: -webkit-gradient(linear, left top, right bottom, color-stop(81%, #ffff88), color-stop(82%, #ffff88), color-stop(82%, #ffff88), color-stop(100%, #ffffc6)); background: -webkit-linear-gradient(-45deg, #ffff88 81%, #ffff88 82%, #ffff88 82%, #ffffc6 100%); background: -o-linear-gradient(-45deg, #ffff88 81%, #ffff88 82%, #ffff88 82%, #ffffc6 100%); background: -ms-linear-gradient(-45deg, #ffff88 81%, #ffff88 82%, #ffff88 82%, #ffffc6 100%); background: linear-gradient(135deg, #ffff88 81%, #ffff88 82%, #ffff88 82%, #ffffc6 100%); filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffff88', endColorstr='#ffffc6', GradientType=1); margin-bottom: 1.2em;"><p style="margin-bottom: 0;"><span style="font-family: 'NanumPen', 'Noto Sans Kr', sans-serif; font-size: 1.6em; color: #555;"><b>
Supported by Oh
</b></span></p></div>

