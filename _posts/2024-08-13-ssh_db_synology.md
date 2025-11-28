---
layout: single
title: "시놀로지 MariaDB에 SSH로 접속하기"
categories:
  - algorithm
---

시놀로지는 상당히 안정적인 **NAS**이면서, 데이터베이스로 **MariaDB**도 쓸 수 있다.  
덕분에 데이터베이스를 학습할 때 사용하기에 꽤 좋은 환경이다.

하지만, 이걸 좀 진지하게 사용하려면 조심해야 한다.  
NAS라는 장비의 특성상 전 세계에서 접속을 시도하는 **해커**들이 많기 때문이다.  
DB에 별 데이터가 없으면 모르겠지만, 중요한 자료들이 많다면 **보안**에 신경을 써야 한다.

SSL을 통해 접속하는 것은 아마도 불가능한 것 같다.  
[인터넷을 찾아보면](https://serverfault.com/questions/1091164/establishing-ssl-with-mariadb10-on-synology){:target="_blank"} **SSL을 사용할 수 없도록** 컴파일된 것이라는 글도 보인다.

하지만, **SSH**를 통해 접속하는 것은 가능하다.  

## 접속 포트 바꾸기

SSH의 기본 포트 번호는 22이다.  
그리고, MariaDB의 기본 포트 번호는 3306이다.

이 두 포트 번호는 사용하면 안 된다.

마음에 드는 포트로 적절히 바꿔준다.

## 강력한 비밀번호 만들기

원래는 인증키를 사용하여 접속하려 했는데, 이상하게 키를 잘 인식하지 않는다.  
그래서 일단 비밀번호로 접속하는 방법을 사용한다.

무엇보다 먼저 준비할 것은 강력한 비밀번호다.

시놀로지는 아이디로 32자까지, 비밀번호로 127자까지 사용할 수 있는 것 같다.  
이왕이면 아이디도 길고 강력한 것으로 만들기로 했다.

아래와 같이 간단한 코드로 아이디와 비밀번호를 만들어낼 수 있다.

```cpp
#include <iostream>
#include <random>

int main()
{
    const char chID[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_.";
    const char chPW[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%^&*()-_=+[]{}|.<>/?";
    
    std::random_device rd; 
    std::mt19937 mt(rd()); 
    std::uniform_int_distribution<int> distID(0, sizeof(chID) - 2);
    std::uniform_int_distribution<int> distPW(0, sizeof(chPW) - 2);
    
    for (int i=0; i < 10; ++i) {
        auto len = 32;
        std::cout << "#" << i << std::endl;
        
        for (auto j = 0; j < len; ++j) {
            auto r = distID(mt);
            std::cout << chID[r];
        }
        std::cout << std::endl;

        len = 127;
        for (auto j = 0; j < len; ++j) {
            auto r = distPW(mt);
            std::cout << chPW[r];
        }
        std::cout << std::endl << std::endl;
    }

    return 0;
}
```

결과는 대략 아래와 같다.

```text
#0
TtgVNSSeH_MsYr1lGIm.2dWxWscmBt2Y
3gTM}LAaxBlvfkLEkg$+6%-h|d82<+VC/i6#[QXVQiM*YhiV86fohakH&m#AgGu)WLB%W-Xoj]ez68<um0sEqfxJ(VGfWHD$?]C%o]x).7]?Ax0^AUqyu3riB0jKBLW

#1
xnv_7LC0_cklQxuUu6VediPRa.Il1tnN
+==E<&jeXPUb<h0OWDcaeDDZS9hzYgON&Erq}d#^b]qDkL]C.Kv[uzVzN#PluD+[aLax.Uy{W_{/hlK>oMl(6R/yK$4S$f%ow$i99H*X%zmn3(ehF4ql{vVNDjvaGMH

#2
Psc1EoVn0nPqiVQAFsvYdr8hz2tDzUR_
lUuu3b#_sI[jL7bH5Lj^=2SLMoB&*Ug$l9.ON6GqRC-oI1!{c4VQKs5uC-LYgc_yWrUF5tY+d]w4dJP67zR5JSSg#B8m|=IP/Koj].%q-5SwS%YruUkWt0Zd4yZ/agk

#3
xIDFH5wcwBZ3jpprQ0ul0HQceLrgH41H
APR(x27SKhxAhp|jm0B0+K42Olst-Iik#SFRl(Rg_Ge{2e*vW5%wmnlKe5473[e(3pgeZlD[!|XDXlhi%Sl>]Go&.&78RY.y[E|OpfA_&5p7ca=$UjgT6}KedR}D?8C

#4
u4aKdr74qFedIzKNtfRYk8tl5gzP_wAD
m3L*k2}!R7}3-eX4(H8yE=a-r5ynM2R5h+H!*[#6gz<l^ozsM]27sNOncO7m<-L$YR]sHC[iJF0{6gT+2Ly67dd.dPmZl[jzYL!g*3Y%$nFBX%UT_Gpr>UM)Kkbobbs

#5
Nutj2XIthD1XfAKB9LwJOph24Dn0xCef
1Ea{4l.gSjO[Kb_8LCO$X0|*8>+q5EPjeCqQ#REo|vHFc+8yJxQKoq_7/cTX^P]SO_ausH?eVm{Dl=.#$)hEwJtXR8)kgkuG]i?!NHp>P85YBo)Xd09vf=Y0r]a4et=
```

## 시놀로지 계정 만들기

SSH를 사용하기 위해서 SSH 전용 계정을 하나 따로 만드는 것이 좋다.  
그런데, 시놀로지에서 **SSH**를 사용하기 위해서는 반드시 **관리자 권한**이 필요하다.

목적을 고려하면 SSH 외엔 다른 권한이 없는 계정을 만드는 것이 좋다.

우선, 제어판에서 **사용자를 추가**한다.

![image](/images/2024-08-13/ssh1_Q.png){: .align-center}
*강력한 id의 압박*

앞에서도 말했듯이 관리자 권한은 필수다.

![image](/images/2024-08-13/ssh2_Q.png){: .align-center}

그리고, 응용 프로그램 권한 할당에서 모든 권한을 없앤다.

![image](/images/2024-08-13/ssh3_Q.png){: .align-center}
*DSM 권한을 없애서 웹을 통한 다른 접속을 원천차단*

## sshd_config 수정

이것만으로 동작이 되어야 하지만, 잘 되지 않는 경우가 있다.  
이 때는 **sshd_config** 파일을 수정해야 한다.

```bash
sudo vi /etc/ssh/sshd_config
```

아래와 같은 내용을 찾아 `yes`로 수정한다.

```text
AllowTcpForwarding no
```

## localhost만 접속 가능하도록 설정

phpMyAdmin 등을 사용해서, **localhost**에서만 접속할 수 있도록 설정한다.  
SSH 터널링을 사용하게 되면 데이터베이스를 원격에서 접속하더라도 **localhost**로 접속하는 것이기 때문이다.

굳이 원격 접속을 허용할 필요가 없다.

![image](/images/2024-08-13/localhost_Q.png){: .align-center}

---

이렇게 하면, SSH를 통해 시놀로지의 DB에 안전하게 접속할 수 있다.
