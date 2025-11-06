---
layout: single
title: "정사각형 내의 사분원을 n×n 분할한 각 블럭의 면적을 적분으로 계산"
date: 2025-11-05 22:20:00 +0900
categories:
  - algorithm
---

아래 그림과 같이 정사각형 내의 사분원을 $$n \times n$$ 분할한 각 블럭의 면적을 부정적분으로 정확히 계산하는 방법 포스팅.

![image](</images/2025-11-05/checks_B_okl_s64_Q.png>){: .align-center}

짧게 말하면, 각 블럭의 면적은 사분원의 높이 함수 $$y(x)=\sqrt{L^2-x^2}$$를 블럭의 세로 구간 $$[y_0,y_1]$$으로 잘라낸 뒤 $$x$$ 방향으로 적분해 정확히 계산할 수 있다.

## 좌표 설정과 블럭 정의

- **정사각형 한 변의 길이:** $$L$$
- **분할 개수:** $$n$$
- **블럭 한 변의 길이:**

  $$
  \Delta=\frac{L}{n}
  $$

- **사분원:** $$x^2+y^2\le L^2,\; x\ge 0,\; y\ge 0$$
- **블럭 $$ (i,j) $$:** $$x\in[x_0,x_1]=[i\Delta,(i+1)\Delta],\quad y\in[y_0,y_1]=[j\Delta,(j+1)\Delta]$$

## 블럭 면적의 정확한 적분식

- **사분원의 높이:**

  $$
  y(x)=\sqrt{L^2-x^2}
  $$

- **임계 $$x$$:** 사분원 높이가 블럭의 $$y$$ 경계와 같아지는 점

  $$
  t_0=\sqrt{L^2-y_0^2},\quad t_1=\sqrt{L^2-y_1^2}\quad(0\le y_0<y_1\le L)
  $$

- **구간 분해:**
  - $$x\le t_1$$: 블럭이 사분원으로 가득 참 → 높이 $$=y_1-y_0$$
  - $$t_1<x\le t_0$$: 일부만 포함 → 높이 $$=y(x)-y_0$$
  - $$x>t_0$$: 사분원 밖 → 높이 $$=0$$

- **면적 공식:** (교집합 구간만 길이/적분, 없으면 0 처리)

  $$
  A_{i,j}=(y_1-y_0)\,\bigl[\min(x_1,t_1)-x_0\bigr]_+\;+\;\int_{\max(x_0,t_1)}^{\min(x_1,t_0)}\bigl(\sqrt{L^2-x^2}-y_0\bigr)\,dx
  $$

  여기서 $$[u]_+=\max(u,0)$$ 이다.

- **부정적분:**  

  $$
  \int\sqrt{L^2-x^2}\,dx=\frac{x}{2}\sqrt{L^2-x^2}+\frac{L^2}{2}\arcsin\!\left(\frac{x}{L}\right)
  $$
  
  따라서,

  $$
  \int_{a}^{b}\bigl(\sqrt{L^2-x^2}-y_0\bigr)\,dx=\Bigl[F(b)-F(a)\Bigr]-y_0(b-a)
  $$

  $$
  F(x)=\frac{x}{2}\sqrt{L^2-x^2}+\frac{L^2}{2}\arcsin\!\left(\frac{x}{L}\right)
  $$

이 식을 그대로 코드로 옮기면 정확한 면적을 계산할 수 있다.

---

## 정규화(단위 면적의 최댓값을 1로)

위의 식은 사반원의 반지름을 1로 변환하여 계산하는 개념이다.\
이를 단위 면적의 최댓값을 1로 계산하도록 바꾸려면 $$ n^2 $$ 을 곱해주면 된다.

  $$
  A'_{i,j}=A_{i,j} \cdot n^2
  $$

---

## C 코드(부정적분으로 정확히 계산)

```c
#include <stdio.h>
#include <math.h>

static inline double F(double x, double L) {
    // sqrt(L^2 - x^2)의 부정적분
    return 0.5 * x * sqrt(fmax(0.0, L*L - x*x)) + 0.5 * L * L * asin(fmin(fmax(x / L, -1.0), 1.0));
}

static inline double pos(double u) {
    return (u > 0.0) ? u : 0.0;
}

double block_area_exact(int i, int j, int n, double L) {
    double delta = L / n;
    double x0 = i * delta, x1 = (i + 1) * delta;
    double y0 = j * delta, y1 = (j + 1) * delta;

    // If the block is entirely beyond the quarter square bounds (defensive checks)
    if (x0 >= L || y0 >= L) return 0.0;

    // Clamp x1, y1 to L to handle boundary blocks safely
    if (x1 > L) x1 = L;
    if (y1 > L) y1 = L;

    // Critical x where circle height meets block vertical bounds
    double t0 = sqrt(fmax(0.0, L*L - y0*y0));
    double t1 = sqrt(fmax(0.0, L*L - y1*y1));

    // Region 1: fully filled height (y1 - y0) over x in [x0, min(x1, t1)]
    double x_full_r = fmin(x1, t1);
    double full_len = pos(x_full_r - x0);
    double area_full = (y1 - y0) * full_len;

    // Region 2: partial height (sqrt(...) - y0) over x in [max(x0, t1), min(x1, t0)]
    double a = fmax(x0, t1);
    double b = fmin(x1, t0);
    double area_partial = 0.0;
    if (b > a)
        area_partial = (F(b, L) - F(a, L)) - y0 * (b - a);

    // Total area for the block
    return area_full + area_partial;
}

int main() {
    int n = 6;        // 격자 분할 개수
    double L = 1.0;   // 정사각형 한 변의 길이

    double *areas = (double *)malloc(sizeof(double) * n * n);

    // 모든 블럭의 정확한 면적을 계산
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            double a = block_area_exact(j, i, n, L);
            areas[i * n + j] = a;
        }
    }

    double sum = 0;
    // 단위 면적의 최댓값을 1로 정규화하고 위에서부터 출력
    for (int i = n - 1; i >= 0; --i) {
        for (int j = 0; j < n; ++j) {
            double v = areas[i * n + j] * n * n;
            printf("%8.6f ", v);
            sum += v;
        }
        printf("\n");
    }
    printf("\nsum: %.12f\n", sum);
    printf("calced area: %.12f\n", M_PI * n * n / 4.0);

    free(areas);
    return 0;
}
```

실행 결과는 아래와 같다.

```text
0.97210532 0.80181330 0.44508798 0.03177121 0.00000000 0.00000000 
1.00000000 1.00000000 1.00000000 0.82859192 0.11559444 0.00000000 
1.00000000 1.00000000 1.00000000 1.00000000 0.82859192 0.03177121 
1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 0.44508798 
1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 0.80181330 
1.00000000 1.00000000 1.00000000 1.00000000 1.00000000 0.97210532 

sum: 28.274333882308
calculated area: 28.274333882308
```

이 결과는 위 그림의 각 블록의 면적이 아래와 같다는 것을 의미한다.

![image](</images/2025-11-05/checks2_B_okl_s64_Q.png>){: .align-center}

그리고, 위 결과에 나온 값을 모두 더한 값과, 계산에 의한 사분원의 면적이 동일하다는 것을 확인할 수 있다.

  $$
  \frac{\pi \cdot 6^2}{4} = 28.274333882308139146\ldots
  $$
