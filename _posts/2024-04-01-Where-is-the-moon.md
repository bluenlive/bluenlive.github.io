---
layout: single
#classes: wide
title: "해와 달의 위치 파이썬으로 간단히 알아보기"
categories:
  - algorithm
---

해와 달의 위치도 ISS 처럼 지구 중심으로부터 기술할 수 있을 것이다.  
하지만, 그렇게 기술하는 것은 일반적으로는 별 의미가 없다.

일단 지구 중심에서 거리가 너무 멀기 때문에 **지구 중심 좌표계**를 사용하면 값이 너무 커지기 때문이다.

해와 달의 위치는 관측자의 위치를 기준으로 방위를 기술하는 것이 일반적이다.

## 해와 달의 위치를 아주 간단히 알아보기

밖으로 나가 하늘을 보며 된다.  
하지만, 방위와 고도를 기술하는 것은 쉽지 않다...

## 해와 달의 위치를 인터넷으로 간단히 알아보기

[Time and Date](https://www.timeanddate.com/astronomy/south-korea/seoul){:target="_blank"}와 같은 사이트를 이용하면 간단하게 해와 달의 위치를 알 수 있다.  
[한국천문연구원](https://astro.kasi.re.kr/life/pageView/6){:target="_blank"}에서는 다양한 정보도 제공한다.

## 파이썬 프로그램으로 알아보기

일단 관측자의 위치를 알아야 한다.  
[MAPS.ie](https://www.maps.ie/coordinates.html){:target="_blank"}와 같은 사이트를 이용하면 간단하게 위도와 경도를 알 수 있다.

다음으로 필요한 라이브러리는 [astral](https://pypi.org/project/astral/){:target="_blank"}이다.  
다음과 같이 하면 간단하게 설치할 수 있다.

```batch
pip install astral
```

아래 코드는 현재 시간을 기준으로 해와 달의 위치를 계산한다.  
관측자의 위치는 서울로 하였다.

{% highlight python linenos %}
from astral import LocationInfo
from astral import sun
from astral import moon
from datetime import datetime
from pytz import timezone
from pytz import utc

location = LocationInfo(name="Seoul", region="Korea", timezone="Asia/Seoul", latitude=37.46707105652381, longitude=127.07507550716402)
tm = datetime.now(tz=utc)

print('현재 시간:', tm.astimezone(timezone(location.timezone)))
print()

azimuth_sun = sun.azimuth(location.observer, tm)
zenith_sun = sun.zenith(location.observer, tm)

print('해의 방위각:', azimuth_sun)
print('해의 천정각:', zenith_sun)
print()

azimuth_moon = moon.azimuth(location.observer, tm)
zenith_moon = moon.zenith(location.observer, tm)
moon_phase = moon.phase(tm)

print('달의 방위각:', azimuth_moon)
print('달의 천정각:', zenith_moon)
print('달의 위상:', moon_phase)
{% endhighlight %}

달의 위상은 0에서 27.99까지의 값을 가진다.  
다음과 같은 의미를 갖는다고 한다.

| 0 .. 6.99 | New Moon |
| 7 .. 13.99 | First Quarter |
| 14 .. 20.99 | Full Moon |
| 21 .. 27.99 | Last Quarter |

실행 결과는 다음과 같다.

```text
현재 시간: 2024-04-02 23:19:22.573637+09:00

해의 방위각: 333.42946227699565
해의 천정각: 133.76930976393237

달의 방위각: 97.89225017980168
달의 천정각: 127.77412008449195
달의 위상: 21.889000000000003
```
