---
layout: single
title: "einsum을 활용한 doppler rate 계산 과정 일부 최적화"
date: 2025-3-1 11:31:00 +0900
categories:
  - algorithm
---

## Cumming 책 4.3. The Range Equation

![image](/images/2025-02-28/CummingCover_Bs64.jpg){: .align-center}

Cumming과 Wong의 명저인 《digital processing of SAR》를 구현하다 적용한 최적화 하나.

Doppler rate를 계산하기 위해서는 radar velocity(effective velocity) $$ V_r $$을 계산해야 한다.\
그리고, 이를 계산하려면 지상에서 빔이 이동하는 속도 $$ V_g $$를 계산해야 한다.

![image](/images/2025-02-28/Cumming_Bs64_Q.png){: .align-center}

위 그림에서 위성의 위치 $$ C $$를 알면 $$ V_s $$를 알 수 있다.\
그리고, $$ C $$와 빔 벡터를 통해 지표면과의 접점 $$ B $$를 알 수 있다.\
그리고, 이 값들을 통해 $$ \theta_{sq} $$, $$ \theta_g $$를 계산할 수 있다.

그러면, 아래와 같은 식이 성립한다.\
$$\begin{align}
\sin \theta_{sq} : \sin \theta_g = V_g : V_s
\end{align}$$

Cumming 책에는 이 식을 각의 크기가 작기 때문에 아래와 같이 근사할 수 있다고 써두었다.\
$$\begin{align}
\theta_{sq} : \theta_g = V_g : V_s
\end{align}$$

## 삼각함수라고?

그런데, 생각을 조금만 바꿔보면 이러한 근사를 생략했을 때 오히려 더 빠르고 정확한 계산을 할 수 있다.

{% capture algo0 %}
두 벡터 $$ \overrightarrow{a} $$, $$ \overrightarrow{b} $$가 있을 때 두 벡터 사이의 각도 $$ \theta $$는 아래와 같이 계산된다.\
$$\begin{align}
\cos \theta = \frac {\overrightarrow{a} \cdot \overrightarrow{b}}{\left\| \overrightarrow{a} \right\| \cdot \left\| \overrightarrow{b} \right\|}
\end{align}$$

그런데, 우리가 원하는 값은 $$ \theta $$가 아니라 $$ \sin \theta $$다.\
따라서, 아래의 식을 적용하면...\
$$\begin{align}
\sin \theta = \sqrt{1 - \cos ^2 \theta}
\end{align}$$

아래와 같이 원하는 값을 도출할 수 있다.\
$$\begin{align}
\sin \theta = \sqrt {1 - \frac {\left ( \overrightarrow{a} \cdot \overrightarrow{b} \right )^2}{\left ( \left\| \overrightarrow{a} \right\| \cdot \left\| \overrightarrow{b} \right\| \right )^2}}
\end{align}$$
{% endcapture %}
{% include bluenlive/algorithm.html content=algo0 %}

## 파이썬에서의 활용 #1

두 개의 1차원 배열 B, C가 있고, V_s를 알고 있다면, V_g는 아래와 같이 계산할 수 있다.
```python
B_to_C = C - B
V_g = V_s * np.sqrt((1 - (np.dot(C, B_to_C) / (np.linalg.norm(C) * np.linalg.norm(B_to_C))) ** 2) /
                    (1 - (np.dot(B, B_to_C) / (np.linalg.norm(B) * np.linalg.norm(B_to_C))) ** 2))
```

여기서 우리가 최적화해야 할 부분은 `np.sqrt` 이후의 내용이다.\
따라서, 이후는 가능한 간략하게 필요한 내용만 적어본다.

정공법으로 적으면 아래와 같다.\
위에 적은 내용과 사실상 동일하다.
```python
C = np.array([1,2,3])
B = np.array([3,4,5])
B_to_C = C - B

np.sqrt((1 - (np.dot(C, B_to_C) / (np.linalg.norm(C) * np.linalg.norm(B_to_C))) ** 2) /
        (1 - (np.dot(B, B_to_C) / (np.linalg.norm(B) * np.linalg.norm(B_to_C))) ** 2))
```

일단, 이후의 과정을 위해 좀 번거롭게 제곱을 각 항으로 분산시킨다.\
물론, 결과값은 동일하다.
```python
np.sqrt((1 - (np.dot(C, B_to_C) ** 2 / (np.linalg.norm(C) ** 2 * np.linalg.norm(B_to_C) ** 2))) /
        (1 - (np.dot(B, B_to_C) ** 2 / (np.linalg.norm(B) ** 2 * np.linalg.norm(B_to_C) ** 2))))
```

그런데, `np.linalg.norm()`은 의외로 좀 느리게 동작한다.\
그래서 아래와 같이 변형해본다.\
이렇게 수정하면 불필요한 **`sqrt()` 다음의 제곱**을 생략할 수 있다.
```python
np.sqrt((1 - (np.dot(C, B_to_C) ** 2 / np.dot(C, C) / np.dot(B_to_C, B_to_C))) /
        (1 - (np.dot(B, B_to_C) ** 2 / np.dot(B, B) / np.dot(B_to_C, B_to_C))))
```

여기서 `np.dot(C, B_to_C)`는 강력한 **einsum**을 활용하면 `np.einsum('i,i->',C,B_to_C)`로 변형할 수 있다.\
그럼 아래와 같이 쓸 수 있다.
```python
np.sqrt((1 - (np.einsum('i,i->',C,B_to_C) ** 2 / np.einsum('i,i->',C,C) / np.einsum('i,i->',B_to_C,B_to_C))) /
        (1 - (np.einsum('i,i->',B,B_to_C) ** 2 / np.einsum('i,i->',B,B) / np.einsum('i,i->',B_to_C,B_to_C))))
```

마지막으로 중복 연산을 방지하기 위해 아래와 같이 수정하면 끝.
```python
sqr_norm_B_to_C = np.einsum('i,i->',B_to_C,B_to_C)
np.sqrt((1 - (np.einsum('i,i->',C,B_to_C) ** 2 / np.einsum('i,i->',C,C) / sqr_norm_B_to_C)) /
        (1 - (np.einsum('i,i->',B,B_to_C) ** 2 / np.einsum('i,i->',B,B) / sqr_norm_B_to_C)))
```

## 파이썬에서의 활용 #2

위에 길게 적긴 했지만, 사실 B, C가 위치 하나만을 기술할 때는 눈에 띄는 성능 향상은 없다.\
이 최적화는 B, C가 연속되는 위성의 위치 수백개 이상을 기술할 때 의미가 있는 방식이다.

여기서는 설명을 간단하게 하기 위해 위성의 위치 2개를 저장한 것으로 기술하는 것으로 시작한다.
```python
C = np.array([[1,2,3],[2,3,4]])
B = np.array([[3,4,5],[4,5,6]])
B_to_C = C - B
```

여기서, 일단 `np.dot()`는 같은 형식으로는 사용할 수 없다.\
이 함수를 이용하려면 아래와 같이 변형해야 한다.
```python
# np.dot(C, B_to_C) 적용 불가
np.array([np.dot(C[i], B_to_C[i]) for i in range(C.shape[0])])
```

list comprehension이라니... 보기만 해도 성능 이슈가 막 터질 것 같은 위기가 느껴진다.\
그래서, 아래와 같이 간단하지만 강력한 **einsum**의 도움을 구해본다.
```python
np.einsum('ij,ij->i', C, B_to_C)
```

`np.linalg.norm()` 역시 완전히 동일하게는 사용할 수 없다.\
2차원 배열에서 각 행의 `norm()`을 계산하려면 축을 지정해야 한다.\
이를 모두 적용하면 아래와 같이 바꿀 수 있다.
```python
np.sqrt((1 - (np.einsum('ij,ij->i', C, B_to_C) / (np.linalg.norm(C,axis=1) * np.linalg.norm(B_to_C,axis=1))) ** 2) /
        (1 - (np.einsum('ij,ij->i', B, B_to_C) / (np.linalg.norm(B,axis=1) * np.linalg.norm(B_to_C,axis=1))) ** 2))
```

앞에서도 적었듯, `np.linalg.norm()`은 좀 느리다.\
따라서, 위와 동일한 최적화를 적용해본다.
```python
sqr_norm_B_to_C = np.einsum('ij,ij->i', B_to_C, B_to_C)
np.sqrt((1 - (np.einsum('ij,ij->i', C, B_to_C) ** 2 / np.einsum('ij,ij->i', C, C) / sqr_norm_B_to_C)) /
        (1 - (np.einsum('ij,ij->i', B, B_to_C) ** 2 / np.einsum('ij,ij->i', B, B) / sqr_norm_B_to_C)))
```

이렇게 하면, 많은 수의 위성 위치에 대해서 최적화된 성능으로 $$ V_g $$를 계산할 수 있다.
