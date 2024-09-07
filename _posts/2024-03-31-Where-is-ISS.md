---
layout: single
#classes: wide
title: "국제우주정거장(ISS) 위치 파이썬으로 간단히 알아보기"
categories:
  - algorithm
---

## 국제우주정거장(ISS)이란

국제우주정거장(International Space Station, ISS)은 지구 궤도를 도는 거대한 구조물이다.  
여러 국가들이 협력하여 만든 것으로, 1998년 11월 20일에 처음으로 인공위성으로 발사되었다.

![image](</images/2024-03-31b/STS-134_ISS_Bs64.jpg>){: .align-center}

비행 고도는 약 400 km이며, 지구를 90분에 한 바퀴 돌고 있다.  
7.5 km/s의 어마어마한 속도로 움직이고 있어, 하루에 16번의 일출과 일몰을 경험한다.

## 우주 물체의 위치 기술

우리가 지상에서 위치를 기술할 때는 대체로 **경위도 좌표계**를 사용한다.  
필요하다면 **고도를 추가로 기술**(이를 LLH라고 통칭함)하기도 한다.  
지상의 물체는 지구가 자전할 때 함께 움직이기 때문에 가능한 것이다.  
이렇게 지구의 자전을 고려한 좌표계를 **ECEF(Earth-Centered, Earth-Fixed)** 좌표계라고 한다.

하지만, ISS 처럼 지구 자전의 영향을 받지 않는 물체는 다른 좌표계를 사용한다.  
이를 **ECI(Earth-Centered Inertial)** 좌표계라고 한다.

그리고, ISS의 위치를 파악하여 지상에서 표현하려면, **ECI 좌표계를 ECEF 좌표계로 변환**해야 한다.

## ISS의 위치 파악

ISS를 비롯한 우주 물체의 위치를 파악하는 방법은 여러 가지가 있다.

가장 간단하게는 [Heavens-Above](https://heavens-above.com){:target="_blank"}와 같은 웹사이트를 이용하는 것이다.  
괜찮은 방법이지만, 파악된 위치를 바탕으로 다른 계산을 하기 어렵다.

또 다른 단순한 방법은 [Open Notify](http://open-notify.org/Open-Notify-API/ISS-Location-Now/){:target="_blank"}와 같은 API를 이용하는 것이다.  
이 곳의 API를 이용하면, ISS의 현재 위치를 알 수 있다.  
하지만, 고도 정보가 나오지 않고, 위치 정보 역시 정확도가 떨어진다.

```json
{
  "message": "success",
  "timestamp": 1711887329,
  "iss_position": {
    "latitude": "-6.2352",
    "longitude": "152.2210"
  }
}
```

좀 더 정석적인 방법은 [TLE(Two-Line Element Set)](https://celestrak.org/NORAD/documentation/tle-fmt.php){:target="_blank"}를 이용하여 계산 하는 것이다.  
TLE는 위성의 궤도를 정의하는 데 사용되는 데이터 포맷이다.  
이 파일은 [CelesTrak](https://celestrak.com){:target="_blank"}과 같은 사이트에서 다운로드할 수 있다.

TLE 파일을 이용하면, ISS의 위치를 시간별로 추적할 수도 있다.  
TLE에서 1차 변환한 위치는 ECI 좌표계로 나오기 때문에, 이를 ECEF 좌표계로 변환해야 한다.  
이 변환을 한번에 해주는 라이브러리로는 [PyEphem](https://pypi.org/project/ephem/){:target="_blank"}, [Skyfield](https://pypi.org/project/skyfield/){:target="_blank"} 등이 있다.

## PyEphem을 이용한 ISS 위치 계산

일단 최신 버전의 TLE를 읽는다.

{% highlight python linenos %}
import urllib.request

def get_iss_tle_as_string():
    with urllib.request.urlopen('https://live.ariss.org/iss.txt') as response:
        data = response.read()

    ret = data.decode('utf-8').split('\n')[:3]

    for i in range(3):
        ret[i] = ret[i].strip()

    return ret    
{% endhighlight %}

그리고, PyEphem을 이용하여 ISS의 위치를 계산한다.

{% highlight python linenos %}
import ephem
from datetime import datetime, timezone

def get_iss_position_ephem():
    iss_tle = get_iss_tle_as_string()
    iss_object_ephem = ephem.readtle(iss_tle[0], iss_tle[1], iss_tle[2])

    time_now = datetime.now(timezone.utc)

    iss_object_ephem.compute(time_now)

    return iss_object_ephem, time_now
{% endhighlight %}

그런데, [PyEphem의 소스 중 earthsat.c](https://github.com/brandon-rhodes/pyephem/blob/master/libastro/earthsat.c){:target="_blank"}를 보면, 이상한 점이 하나 눈에 띈다.  
여기서 도출된 ECEF 좌표는 **WGS84 좌표계가 아니다**.  
심지어 코드나 주석에 언급되는 **WGS66도 아니다**.

정확한 직교좌표를 얻으려면, PyEphem의 소스를 보고 역셈하는 코드를 직접 만들어야 한다.

{% highlight python linenos %}
import numpy as np

def InvGetSubSatPoint(Lat, Long, Alt):
    EarthRadius = 6378160             # meters
    EarthFlat = 1/298.25              # Earth Flattening Coeff.

    r = EarthRadius*(np.sqrt(1-(2*EarthFlat-EarthFlat**2)*np.sin(Lat)**2)) + Alt

    x = r * np.cos(Lat) * np.cos(Long)
    y = r * np.cos(Lat) * np.sin(Long)
    z = r * np.sin(Lat)

    return [x, y, z]
{% endhighlight %}

이렇게 하면 간단하게 **ECEF 직교좌표**를 얻을 수 있다.

여담이지만, 전술한 [Open Notify](http://open-notify.org/Open-Notify-API/ISS-Location-Now/){:target="_blank"}의 API도 이 방법을 사용한다.  
그것도 마지막에 기술한 직교좌표 변환은 빼고.  
따라서, 여기서 얻은 좌표에서 **위도는 정확도가 많이 떨어진다**.

## SkyField를 이용한 ISS 위치 계산

SkyField는 PyEphem과 사용법이 약간 다르다.  
우선 TLE 파일을 웹에서 읽을 때는 url만 넣어주면 된다.

{% highlight python linenos %}
from skyfield.api import load

def get_iss_object_skyfield():
    satellites = load.tle_file(url='https://live.ariss.org/iss.txt', reload=True)

    iss = satellites[0]

    return iss
{% endhighlight %}

인자로 시간만 넣어주면 직교좌표와 WGS84 좌표를 한번에 얻을 수 있다.

{% highlight python linenos %}
from datetime import datetime, timezone
from skyfield.api import wgs84
from astropy import units as u

def get_iss_position_skyfield():
    iss = get_iss_object_skyfield()

    ts = load.timescale()
    time_now = datetime.now(timezone.utc)

    geocentric = iss.at(ts.from_datetime(time_now))
    subpoint = wgs84.subpoint(geocentric)

    xyz = subpoint.itrs_xyz.to(u.m)
    xyz = xyz.transpose()

    return xyz, subpoint, time_now
{% endhighlight %}

## 결론

같은 시간에 대해 PyEphem과 Skyfield로 계산한 결과를 비교하면 아래와 같다.  
두 결과의 오차는 약 35.08m로 거의 일치한다고 볼 수 있다.

```text
ISS position at specific timestamp with ephem
위도: -6:11:54.2 경도: 152:11:30.8 고도: 422383.75
ISS의 위치: [-5979798.722588209, 3153872.393587607, -734238.5830070344]
최신 TLE: ['ISS (ZARYA)', '1 25544U 98067A   24091.40811343  .00044324  00000-0  78509-3 0  9999', '2 25544  51.6412 341.0008 0005066  18.1497 316.6204 15.49815133446471']
현재 시간: 2024-03-31 12:15:29+00:00

ISS position at specific timestamp with Skyfield
[#################################] 100% iss.txt
[-5979754.8106158   3153898.55929926  -734236.95911065] m
WGS84 latitude -6.2373 N longitude 152.1915 E elevation 422381.6 m
2024-03-31 12:15:29+00:00
```

덧1. 비행 고도가 약 400 km라고 전술했는데, 데이터 확인 결과 고도는 약 422 km이다.

덧2. ISS의 위치를 실시간으로 확인할 수 있는 사이트들은 아래와 같다.

- [Heavens-Above](https://heavens-above.com){:target="_blank"}
- [N2YO](https://www.n2yo.com){:target="_blank"}
- [NASA](https://spotthestation.nasa.gov){:target="_blank"}
