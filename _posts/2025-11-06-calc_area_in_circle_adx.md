---
layout: single
title: "원 일부의 면적을 적분으로 계산"
date: 2025-11-06 01:20:00 +0900
categories:
  - algorithm
---

이 글은 [이전 글](/algorithm/calc_area_in_circle/)의 일부 내용에 대한 부가적인 설명 글.

![image](/images/2025-11-06/checks_B_okl_s64_Q.png){: .align-center}

위 그림에서 진한 색으로 표시된 영역의 면적을 적분으로 계산해보고 싶었다.\
프로그램으로 간단하게 계산하기 위해서는 근사해서 계산하는 방법이 있다.\
그런데, 좀 더 엄밀하게 계산하는 방법을 찾고 싶었다.

## Wolfram Alpha로 계산

![image](/images/2025-11-06/wolframalpha_B_okl_s64_Q.png){: .align-center}

[Wolfram Alpha](https://www.wolframalpha.com/input?i=integral+from+2+to+3+of+sqrt%2825-x%5E2%29&lang=ko){:target="_blank"}를 통해 계산해보니 위와 같은 결과가 나왔다.\
이 결과를 보면서 다음과 같은 부정적분 식을 추정할 수 있었다.

  $$
  \int\sqrt{L^2-x^2}\,dx=\frac{1}{2}x \sqrt{L^2-x^2}-L^2 \cdot \arctan\!\left(\frac{\sqrt{L^2-x^2}}{x + L}\right)+C
  $$

## MS Copilot (GPT-5) 활용

{: .bluebox-yellow}
sqrt(L^2 - x^2)의 부정적분을 계산해줘. L은 상수이고, x에 대해서 계산해줘.

이 질문에 대해 MS Copilot은 다음과 같은 답을 내놓았다.

<div style="padding: 10px; border: 1px dashed #c1c1c1; margin-bottom: 1.2em;" markdown="1">
좋은 질문이에요! 우리가 풀고자 하는 적분은  

$$
\int \sqrt{L^2 - x^2}\, dx
$$

입니다. 여기서 $$ L $$은 상수입니다.  

---

### 풀이 과정 ✨

1. **삼각 치환**  
   $$ x = L \sin \theta $$ 라고 두면,

   $$
   dx = L \cos \theta \, d\theta, \quad \sqrt{L^2 - x^2} = \sqrt{L^2 - L^2 \sin^2 \theta} = L \cos \theta
   $$

   따라서 적분은

   $$
   \int \sqrt{L^2 - x^2}\, dx = \int (L \cos \theta)(L \cos \theta \, d\theta) = L^2 \int \cos^2 \theta \, d\theta
   $$

2. **삼각함수 제곱 적분**  
   $$\cos^2 \theta = \tfrac{1}{2}(1 + \cos 2\theta)$$ 이므로,

   $$\begin{align*}
   L^2 \int \cos^2 \theta \, d\theta & = \frac{L^2}{2} \int (1 + \cos 2\theta)\, d\theta\\
   & = \frac{L^2}{2} \left( \theta + \frac{1}{2}\sin 2\theta \right) + C
   \end{align*}$$

3. **원래 변수로 복원**  
   $$\theta = \arcsin\left(\tfrac{x}{L}\right)$$ 이고,

   $$
   \sin 2\theta = 2 \sin \theta \cos \theta = \frac{2x}{L} \cdot \frac{\sqrt{L^2 - x^2}}{L} = \frac{2x \sqrt{L^2 - x^2}}{L^2}
   $$

   따라서,

   $$
   \frac{L^2}{2} \left( \theta + \frac{1}{2}\sin 2\theta \right)
   = \frac{L^2}{2} \arcsin\left(\frac{x}{L}\right) + \frac{x}{2}\sqrt{L^2 - x^2}
   $$

---

### 최종 결과 ✅

$$
\int \sqrt{L^2 - x^2}\, dx = \frac{x}{2}\sqrt{L^2 - x^2} + \frac{L^2}{2}\arcsin\!\left(\frac{x}{L}\right) + C
$$
</div>

여기서 다음과 같은 부정적분 식을 알 수 있다.

  $$
  \int\sqrt{L^2-x^2}\,dx=\frac{x}{2}\sqrt{L^2-x^2}+\frac{L^2}{2}\arcsin\!\left(\frac{x}{L}\right)+C
  $$

Wolfram Alpha의 결과와 이 식은 서로 달라 보이지만, 범위를 지정해서 계산해보면 결과가 같음을 확인할 수 있다.

---

덧. 이 글과 [앞 글](/algorithm/calc_area_in_circle/) 모두 핵심적인 내용들은 AI를 통해 작성한 글들임

<div class="qa-question" markdown="1">
❓ **질문**  
여기에 질문 내용을 작성합니다.
</div>

<div class="qa-answer" markdown="1">
🤖 **답변**  
여기에 Copilot의 답변을 작성합니다.
</div>
