---
layout: single
title: "회전각 둘을 연속적으로 계산해야 할 때 생각할 지점 하나"
date: 2025-08-03 01:03:00 +0900
categories:
  - algorithm
---

## 연속적인 오일러 회전의 순서에 따른 결과 차이

오일러 회전을 연속적으로 계산할 때, $$roll$$, $$pitch$$, $$yaw$$ 순서로 계산할 때와 역순으로 계산할 때는 결과가 다르다.\
아래 그림에서 $$beam1(= +z)$$을 $$beam2$$로 회전변환 할 때 $$\theta$$각과 $$\phi$$각을 적용하는 순서에 따라 결과가 다르다는 뜻.

![image](</images/2025-08-03/graph_B_Q.png>){: .align-center}
*이 그림에서는 고각($$\theta$$)을 먼저 계산하는 느낌으로 표현되었음\*

게다가, 어떤 각을 먼저 계산하든, 회전 결과 $$beam2$$를 $$beam1$$과 비교하면 둘 사이의 각은 의도한 $$\theta$$, $$\phi$$각과 다르다.\
이 점은 아래 코드로 간단히 확인할 수 있다.

```python
import numpy as np

def quaternion_from_vectors(v0, v1):
    v0 = v0 / np.linalg.norm(v0)
    v1 = v1 / np.linalg.norm(v1)
    dot = np.dot(v0, v1)

    if dot < -1 + 1e-6:
        # 180도 회전
        axis = np.cross(v0, np.array([1, 0, 0]))
        if np.linalg.norm(axis) < 1e-6:
            axis = np.cross(v0, np.array([0, 1, 0]))
        axis = axis / np.linalg.norm(axis)
        return np.array([0, *axis])
    elif dot > 1 - 1e-6:

        # 동일한 방향
        return np.array([1, 0, 0, 0])
    else:
        # 일반적인 경우
        axis = np.cross(v0, v1)
        s = np.sqrt((1 + dot) * 2)
        inv_s = 1 / s
        return np.array([s * 0.5, axis[0] * inv_s, axis[1] * inv_s, axis[2] * inv_s])

# q1·q2
def quaternion_multiply(q1, q2):
    w1, x1, y1, z1 = q1
    w2, x2, y2, z2 = q2
    return np.array([
        w1 * w2 - x1 * x2 - y1 * y2 - z1 * z2,
        w1 * x2 + x1 * w2 + y1 * z2 - z1 * y2,
        w1 * y2 - x1 * z2 + y1 * w2 + z1 * x2,
        w1 * z2 + x1 * y2 - y1 * x2 + z1 * w2
    ])

def quaternion_rotate_vector(q, v):
    q_conjugate = np.array([q[0], -q[1], -q[2], -q[3]])
    v_quat = np.array([0, *v])
    rotated_v = quaternion_multiply(quaternion_multiply(q, v_quat), q_conjugate)
    return rotated_v[1:]

# 종방향 각도(el)과 횡방향 각도(az)를 이용하여 빔 벡터를 계산합니다.
# el은 roll각(x축 회전)과 비슷하고, az는 pitch각(y축 회전)과 비슷한 개념
def quaternion_from_beam(el, az):
    # 종방향 회전 (roll = el)
    q_el = np.array([
        np.cos(el / 2), 
        np.sin(el / 2), 
        0, 
        0
    ])
    
    # 횡방향 회전 (pitch = az)
    q_az = np.array([
        np.cos(az / 2), 
        0, 
        np.sin(az / 2), 
        0
    ])
    
    # 두 회전을 결합하여 최종 쿼터니언을 계산
    # 통상적인 연산 순서는 yaw --> pitch -> roll 임 (여기서는 azimuth -> elevation 순서로 계산됨)
    q = quaternion_multiply(q_el, q_az)
    return q


# 두 벡터 v0와 v1 사이의 elevation 각도를 계산합니다.
def calc_el_angle(v0, v1):
    angle = -(np.arctan2(v1[1], v1[2]) - np.arctan2(v0[1], v0[2]))
    return angle


# 두 벡터 v0와 v1 사이의 azimuth 각도를 계산합니다.
def calc_az_angle(v0, v1):
    angle = np.arctan2(v1[0], v1[2]) - np.arctan2(v0[0], v0[2])
    return angle


if __name__ == "__main__":
    # el 각은 roll각(x축 회전)과 비슷한 개념
    # az 각은 pitch각(y축 회전)과 비슷한 개념
    el_az_angles = [[10, 0], [0, -10], [86.3, 89.2], [42.195, -32.1], [-21, -37], [-4, 2.5]]

    for el, az in el_az_angles:
        print("# Elevation:", el)
        print("# Azimuth:  ", az)

        el = np.deg2rad(el)
        az = np.deg2rad(az)

        # 기준 빔 벡터
        # 이 빔 벡터와 연산된 빔 벡터 사이의 회전을 계산하고
        # 두 빔 벡터 사이의 el, az 각을 각각 계산함
        beam_from = np.array([0, 0, 1])
        beam_to = quaternion_rotate_vector(quaternion_from_beam(el, az), beam_from)
        print("- Beam from:", beam_from)
        print("- Beam to:", beam_to)

        # 두 벡터 사이의 elevation 각도 계산
        el_angle = calc_el_angle(beam_from, beam_to)
        print("- Elevation angle (degrees):", np.round(np.rad2deg(el_angle), 8))
        
        # 두 벡터 사이의 azimuth 각도 계산
        az_angle = calc_az_angle(beam_from, beam_to)
        print("- Azimuth angle (degrees):", np.round(np.rad2deg(az_angle), 8))

        print()
```

위 코드를 실행하면 다음과 같은 결과가 나온다.

```text
# Elevation: 10
# Azimuth:   0
- Beam from: [0 0 1]
- Beam to: [ 0.         -0.17364818  0.98480775]
- Elevation angle (degrees): 10.0
- Azimuth angle (degrees): 0.0

# Elevation: 0
# Azimuth:   -10
- Beam from: [0 0 1]
- Beam to: [-0.17364818  0.          0.98480775]
- Elevation angle (degrees): -0.0
- Azimuth angle (degrees): -10.0

# Elevation: 86.3
# Azimuth:   89.2
- Beam from: [0 0 1]
- Beam to: [ 9.99902524e-01 -1.39330778e-02  9.01011726e-04]
- Elevation angle (degrees): 86.3
- Azimuth angle (degrees): 89.94837081

# Elevation: 42.195
# Azimuth:   -32.1
- Beam from: [0 0 1]
- Beam to: [-0.53139858 -0.56897447  0.62760147]
- Elevation angle (degrees): 42.195
- Azimuth angle (degrees): -40.25503681

# Elevation: -21
# Azimuth:   -37
- Beam from: [0 0 1]
- Beam to: [-0.60181502  0.28620537  0.74559048]
- Elevation angle (degrees): -21.0
- Azimuth angle (degrees): -38.90927699

# Elevation: -4
# Azimuth:   2.5
- Beam from: [0 0 1]
- Beam to: [0.04361939 0.06969008 0.99661459]
- Elevation angle (degrees): -4.0
- Azimuth angle (degrees): 2.50609697
```

위 코드는 $$\phi$$각 → $$\theta$$각 순으로 회전이동을 한 뒤에 원래 벡터와의 $$\theta (el)$$, $$\phi (az)$$ 각을 계산하는 코드이다.\
$$\theta$$각과 $$\phi$$각 중 하나가 0이면 원하는 결과가 도출되지만, 둘 다 0이 아닌 경우엔 $$\phi$$각이 다르게 계산된다.

## 회전 비가환성의 해결

위와 같은 결과가 나오는 이유는 회전 비가환성(non-commutative) 때문이다.\
즉, 회전 순서에 따라 결과가 다르다는 것이다.

이 문제를 해결하기 위해서는 먼저 계산하는 $$\phi$$각에 대해 발생할 수 있는 오차를 미리 반영해야 한다.\
$$\phi$$각과 $$\theta$$각을 동시에 적용한 벡터를 생성한 뒤 $$\theta$$각을 역으로 적용하면 된다.\
아래 코드는 이를 구현한 코드이다.

```python
# 회전 비가환성(non-commutativity)을 해결할 수 있는 az 각도를 계산
# 이 함수의 결과만큼 az 각을 적용한 뒤 el 각을 적용하면
# el, az 각이 각각 종방향과 횡방향으로 정확히 적용됨
def calc_noncommutative_az_angle(el, az):
    az_ori = ((az + 180) % 360) - 180
    az_ori = 90 if az_ori > 90 else -90 if az_ori < -90 else az_ori

    el = np.deg2rad(el)
    az = np.deg2rad(az)

    x0 = np.tan(az)
    y0 = np.tan(el)
    z0 = 1.0

    # [x0, y0, z0]을 x 축 기준으로 el만큼 회전이동 시켜 [x1, y1, z1] 생성
    x1 = x0
    y1 = y0 * np.cos(el) - z0 * np.sin(el)
    z1 = y0 * np.sin(el) + z0 * np.cos(el)

    # y1은 0이 되어야 함
    #print(x1, y1, z1)

    # [x1, z1]와 [0, 1] 벡터의 사잇각(azimuthal angle)을 계산
    v1 = np.array([x1, z1])
    v2 = np.array([0, 1])
    v1_norm = v1 / np.linalg.norm(v1)
    v2_norm = v2 / np.linalg.norm(v2)
    dot = np.clip(np.dot(v1_norm, v2_norm), -1.0, 1.0)
    angle_rad = np.arccos(dot)
    angle_deg = np.rad2deg(angle_rad)

    if az_ori < 0:
        angle_deg = -angle_deg

    return angle_deg
```

처음 기술한 코드에 이 함수를 적용한 뒤 결과를 출력하면 아래와 같이 나온다.

```text
# Elevation: 10
# Azimuth:   0
- derived azimuth angle: 0.0
- Beam from: [0 0 1]
- Beam to: [ 0.         -0.17364818  0.98480775]
- Elevation angle (degrees): 10.0
- Azimuth angle (degrees): 0.0

# Elevation: 0
# Azimuth:   -10
- derived azimuth angle: -10.0
- Beam from: [0 0 1]
- Beam to: [-0.17364818  0.          0.98480775]
- Elevation angle (degrees): -0.0
- Azimuth angle (degrees): -10.0

# Elevation: 86.3
# Azimuth:   89.2
- derived azimuth angle: 77.79053214
- Beam from: [0 0 1]
- Beam to: [ 0.97738096 -0.21104549  0.0136477 ]
- Elevation angle (degrees): 86.3
- Azimuth angle (degrees): 89.2

# Elevation: 42.195
# Azimuth:   -32.1
- derived azimuth angle: -24.92630127
- Beam from: [0 0 1]
- Beam to: [-0.42145214 -0.60909162  0.67185228]
- Elevation angle (degrees): 42.195
- Azimuth angle (degrees): -32.1

# Elevation: -21
# Azimuth:   -37
- derived azimuth angle: -35.12651334
- Beam from: [0 0 1]
- Beam to: [-0.57538379  0.29310325  0.76356007]
- Elevation angle (degrees): -21.0
- Azimuth angle (degrees): -37.0

# Elevation: -4
# Azimuth:   2.5
- derived azimuth angle: 2.49391782
- Beam from: [0 0 1]
- Beam to: [0.04351333 0.0696904  0.9966192 ]
- Elevation angle (degrees): -4.0
- Azimuth angle (degrees): 2.5
```

## 코드 최적화

회전 비가환성을 해결하고 보니 위의 코드는 최적화가 좀 필요하다.\
최종적으로 필요한 사잇각을 계산한 뒤에 원래 각의 부호를 적용하는 방식으로 구현했는데, 뭔가 좀 복잡하다.

```python
# 위 함수의 1차 최적화 버전
def calc_noncommutative_az_angle_v2(el, az):
    el = np.deg2rad(el)
    az = np.deg2rad(az)

    x0 = np.tan(az)
    y0 = -np.tan(el)
    z0 = 1
    
    # x0, y0, z0 벡터를 x축을 기준으로 -el 만큼 회전
    x1 = x0
    y1 = y0 * np.cos(-el) - z0 * np.sin(-el)
    z1 = y0 * np.sin(-el) + z0 * np.cos(-el)

    theta = np.arctan2(x1, z1)
    return np.rad2deg(theta)
```

이제 좀 간결해졌다.\
그리고, 이렇게 정리하고 보니 좀 더 정리할 지점이 보인다.

```python
# 최종 최적화 버전
def calc_noncommutative_az_angle_v3(el, az):
    el = np.deg2rad(el)
    az = np.deg2rad(az)

    x1 = np.tan(az)
    z1 = np.tan(el) * np.sin(el) + np.cos(el)

    theta = np.arctan2(x1, z1)
    return np.rad2deg(theta)
```

이렇게 계산된 각각 함수의 결과는 다음과 같다.

```text
# Elevation: 10
# Azimuth:   0
- Calculated azimuth angle #1: 0.0 degrees
- Calculated azimuth angle #2: 0.0 degrees
- Calculated azimuth angle #3: 0.0 degrees

# Elevation: 0
# Azimuth:   -10
- Calculated azimuth angle #1: -10.0 degrees
- Calculated azimuth angle #2: -10.0 degrees
- Calculated azimuth angle #3: -10.0 degrees

# Elevation: 86.3
# Azimuth:   89.2
- Calculated azimuth angle #1: 77.79053214 degrees
- Calculated azimuth angle #2: 77.79053214 degrees
- Calculated azimuth angle #3: 77.79053214 degrees

# Elevation: 42.195
# Azimuth:   -32.1
- Calculated azimuth angle #1: -24.92630127 degrees
- Calculated azimuth angle #2: -24.92630127 degrees
- Calculated azimuth angle #3: -24.92630127 degrees

# Elevation: -21
# Azimuth:   -37
- Calculated azimuth angle #1: -35.12651334 degrees
- Calculated azimuth angle #2: -35.12651334 degrees
- Calculated azimuth angle #3: -35.12651334 degrees

# Elevation: -4
# Azimuth:   2.5
- Calculated azimuth angle #1: 2.49391782 degrees
- Calculated azimuth angle #2: 2.49391782 degrees
- Calculated azimuth angle #3: 2.49391782 degrees
```

서로 동일한 값이 나오는 것을 볼 수 있다.\
실은 연산 방식에 따라 **소수점 아래 14자리** 정도에서 오차가 있다.\
하지만 그 정도의 각도는 실세계에서는 아무 의미가 없는 수준.
