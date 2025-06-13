---
layout: single
title: "간단한 수학 문제 2가지"
categories:
  - etc
---

인터넷 커뮤니티에 재미있는 수학 문제가 올라왔다.\
재미있어 보여 한번 풀어봤다.

![image](</images/2025-01-27/math1_Bs64.jpg>){: .align-center}

1개, 2개, 3개... 씩 그룹 지어 생각하면 쉽게 풀 수 있다.\
$$\begin{align}
\left( \frac{1}{1} \right),\ \left( \frac{1}{2},\ \frac{2}{1} \right),\ \left( \frac{1}{3},\ \frac{2}{2},\ \frac{3}{1} \right),\cdots
\end{align}$$

199번째 항을 구하려면 일단, 이 항이 몇 번째 그룹인지와 그 그룹에서 몇 번째 항인지 알아야 한다.\
각 그룹의 항의 개수가 1개, 2개, 3개... 순으로 증가하므로, 199번째 항은 20번째 그룹의 9번째 항이다.\
$$\begin{align}
\sum_{i=1}^{19}i = \frac{19\cdot 20}{2} = 190
\end{align}$$

따라서, 199번째 항은 $$\begin{align} \frac{9}{12} \end{align}$$이다.

---

![image](</images/2025-01-27/math2_Bs64.jpg>){: .align-center}

정육면체를 그림과 같이 쌓을 때, 사용되는 전체 정육면체의 개수를 구하는 문제이다.

일단 한 층에 사용되는 정육면체의 개수를 구해야 한다.\
첫 번째 층에는 1개, 두 번째 층에는 1+3+1=5개, 세 번째 층에는 1+3+5+3+1=13개... 이런 식으로 쌓아가면 된다.

이 부분을 일반화해보면 다음과 같다.\
$$\begin{align}
f(n) & = 1+3+5+\cdots+(2n-1)+\cdots+5+3+1\\
& = 2\left(1+3+5+\cdots+\left(2n-1\right)\right) - (2n-1)\\
& = 2n^2-2n+1
\end{align}$$

그리고, 한 행에 사용되는 정육면체의 개수가 위와 같을 때 층의 개수가 $$n$$이라면 전체 정육면체의 개수는 다음과 같다.\
$$\begin{align}
g(n) & = \sum_{i=1}^{n}\left(2i^2-2i+1\right)\\
& = \frac{2n(n+1)(2n+1)}{6} - \frac{2n(n+1)}{2} + n\\
& = \frac{n(n+1)(2n+1)}{3} - n^2
\end{align}$$

문제에 언급된 $$n=4$$인 경우 및 $$n=10$$인 경우의 결과는 다음과 같다.\
$$\begin{align}
g(4) &= \frac{4\cdot5\cdot9}{3} - 4^2 = 44\\
g(10) &= \frac{10\cdot11\cdot21}{3} - 10^2 = 670
\end{align}$$
