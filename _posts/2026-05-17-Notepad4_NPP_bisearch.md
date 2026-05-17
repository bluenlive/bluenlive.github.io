---
layout: single
title: "NPP 플러그인과 이진탐색에 대한 가벼운 고찰"
date: 2026-05-17 22:37:00 +0900
categories:
  - algorithm
---

## 1. 최초 기능 구현

[Notepad4](https://github.com/zufuliu/notepad4)에는 **좌우 정렬** 기능이 있다.\
마치 **워드프로세서**에서 **문단 정렬**을 하듯이 정렬하는 기능이다.

그런데, 이 기능은 **모든 글자**를 **동일한 폭**으로 놓고 정렬한다.\
따라서, 한국어 등의 환경에서는 뭔가 이상하게 동작할 수밖에 없다.

본 블로그에서 배포하는 버전은 여기에 기능 하나를 보강했다.\
유니코드 테이블을 뒤져서 **반각, 전각 글자 및 폭이 없는 글자**에 대한 폭 계산을 별도로 하는 것.

물론 엄밀하게 규정된 글자의 폭이란 게 없긴 하지만, 최대한 반영한 숨은 내용은 다음과 같다.

{: .bluebox-blue}
* 눈에 보이지 않는 **제로 너비 문자 (Zero-width joiners, 제어 문자)**
* 앞 글자에 기생하여 폭을 차지하지 않는 **결합 문자 (Combining marks)**
* 유니코드 테이블 사방에 흩어져 있는 **전각 기호, 반각 기호, 특수 수학 기호**들

이를 위해 **유니코드 전체 영역을 세밀한 '범위(Interval/Range)' 단위로 쪼개어** 글자 폭을 계산했다.

## 2. 기존 구현: 직접 구현한 범위 검색용 이진 탐색 (Before)

유니코드에 산재한 세부 범위들을 고속으로 탐색하기 위해, **구간(Interval) 검색용 이진 탐색 함수를 직접 구현**했었다.\
순차 탐색(Linear Search)으로 이 범위들을 직접 훑는 건 **성능 손실**이 너무 크고.

```cpp
struct interval {
    int first;
    int last;
};

/* auxiliary function for binary search in interval table */
static constexpr int bisearch(const int ucs, const struct interval *table, int max) {
    int min{ 0 };
    int mid{ 0 };

    // 예외적인 경계 조건 먼저 스크리닝
    if ((ucs < table[0].first) || (ucs > table[max].last))
        return 0;

    // 수제 이진 탐색 루프
    while (max >= min) {
        mid = (min + max) / 2;
        if (ucs > table[mid].last)
            min = mid + 1;
        else if (ucs < table[mid].first)
            max = mid - 1;
        else
            return 1; // 범위 안에서 매칭 성공
    }

    return 0;
}
```

이 수제 `bisearch()` 코드는 컴파일 타임 상수(`constexpr`)로 작동하며 오랫동안 훌륭하게 제 역할을 해주었다.\
그러다 문득 코드 리뷰 과정에서 이런 생각이 들었다.

{% include bnl_quote.html
   align="center"
   content="이미 C++ STL에 검증된 고성능 이진 탐색 함수가 있는데, 왜 굳이 이 코드를 내가 유지보수하고 있었지?" %}

그렇게 STL을 이용한 전면적인 리팩토링을 하기로 했다.

## 3. C++ STL에 구현되어 있는 이진 탐색 함수들

C++ 표준 라이브러리(`<algorithm>`)는 안전하고 컴파일러 최적화가 극대화된 4가지 이진 탐색 도구를 제공한다.

{: .bluebox-green}
* `std::binary_search`: 값이 존재하는지 여부(`bool`)만 반환. 위치는 알 수 없음
* `std::lower_bound`: 지정한 값보다 **크거나 같은 첫 번째 원소**의 위치(Iterator) 반환.
* `std::upper_bound`: 지정한 값을 **초과하는 첫 번째 원소**의 위치를 반환.
* `std::equal_range`: `lower_bound`와 `upper_bound` 결과를 한 번에 반환하여 중복 데이터 구간을 캡처.

정렬된 유니코드 테이블 테이블에서 정확한 위치(Iterator)를 찾아내어 데이터를 다뤄야 한다.\
따라서, 이진 탐색의 정석인 `std::lower_bound`를 사용해 기존의 수제 `bisearch` 루프를 대체하면 된다.

## 4. 어떻게 변경했는가 (After)

### 4.1. STL 기반으로 정제된 코드

기존에 구현했던 `while (max >= min)` 기반의 복잡한 이진 탐색 제어 코드를 걷어내고, STL에 탐색을 위임했다.\
직접 인덱스(`min`, `max`, `mid`)를 계산하던 루프는 `std::lower_bound`와 람다 함수를 쓰면 몇 줄로 적을 수 있다.

```cpp
#include <algorithm>
#include <iterator>

static constexpr bool bisearch(const int ucs, const struct interval *table, int max) {
    if (ucs < table[0].first || ucs > table[max].last)
        return false;

    // max는 최대 인덱스이므로, 탐색 범위 크기는 max + 1
    const auto it = std::lower_bound(table, table + max + 1, ucs,
        [](const struct interval& i, int val) {
            return i.last < val;
        });

    return (it != table + max + 1 && ucs >= it->first);
}
```

### 4.2. C++20에서는 좀 더 간결히 기술 가능

C++20에서는 `std::ranges::lower_bound`를 사용해서 좀 더 깔끔하게 쓸 수 있다.\
이 경우는 `max`를 넘길 필요가 없다.

```cpp
#include <algorithm>
#include <span>

static constexpr bool bisearch_modern(const int ucs, std::span<const interval> table) {
    if (table.empty() || ucs < table.front().first || ucs > table.back().last)
        return false;

    const auto it = std::ranges::lower_bound(table, ucs, {}, &interval::last);

    return (it != table.end() && ucs >= it->first);
}
```

## 5. STL 이진 탐색 함수에 대해 한 발짝만 더 들여다보면…

`std::lower_bound`가 내부적으로 돌아가는 규칙들을 들여다보자.

### ① 람다 조건식이 `i.last < val` 이나 `m.key < key` (작다) 인 이유

`lower_bound`는 "크거나 같은 첫 번째 지점"을 찾는데 수식은 '작다(`<`)'를 쓴다.\
이 조건식은 **"루프를 끝낼 조건"**이 아니라 **"오른쪽으로 계속 탐색을 진행할 조건"**이기 때문이다.

구간(Interval) 검색 버전을 보면 조금은 이해가 쉽다.

{: .bluebox-yellow}
* 알고리즘이 배열의 처음부터 우측으로 검사해가며 *"이 구간의 끝(`i.last`)이 내가 찾는 값(`val`)보다 작니?"*라고 묻는다.
* `true`가 나오면 "현재 구간은 타겟보다 완전히 왼쪽에 있으니 더 오른쪽 영역을 뒤져라"가 된다.
* 그러다 **처음으로 `false`가 나오는 경계선**을 포착하면, "이 구간의 끝이 타겟보다 크거나 같다"는 뜻이 되므로 루프를 멈춘다.

### ② 람다 함수의 인자 지정 규칙

`std::lower_bound`에 커스텀 람다를 붙일 때 인자의 순서는 표준 사양으로 엄격하게 약속되어 있다.

```cpp
[](const struct interval& i, int val)
```

**"첫 번째 인자는 배열에서 꺼낸 데이터 원소(Left), 두 번째 인자는 사용자가 찾으려는 키값(Right)"** 순서여야 한다.

참고로 초과하는 지점을 찾는 `std::upper_bound`는 이 인자 순서가 반대로 뒤집힌다.\
이는 C++ 설계자들이 오직 '작다(`<`)' 연산자 하나만으로 모든 탐색 논리를 통일하려다 생긴 결과라고 한다.

### ③ 왜 `std::end()`하고만 비교할까?

목표 값이 배열의 첫 번째 값보다 작으면 `lower_bound`는 정상 포인터인 `std::begin()`을 반환, 메모리 참조가 안전하다.\
반면, 배열의 모든 값보다 크면 배열 밖의 허공인 `std::end()`를 반환하며, 이때 무작정 접근하면 **크래시**가 난다.

기존 수제 코드에서 `if ((ucs < table[0].first) || (ucs > table[max].last))`로 앞뒤 경계를 수동 차단했던 예외 처리가, STL에서는 `it != table + max + 1`로 최소한의 우측 안전선만 확보해 준 뒤, 안전 구역 안에서 `ucs >= it->first`라는 논리 검사로 구간 포함 여부를 판정하는 형태로 전환된 것이다.

## 맺음말

실제 이러한 수정으로 얻어지는 동작 성능의 증감이나 바이너리 크기의 변화 등은 없다.\
성능도 대동소이하고, 실행파일의 크기는 완전히 동일했다.

그렇다면 **더 깔끔한 코드**를 위해 STL를 쓰는 편이 더 낫겠다.\
그런데, 이거 대체 왜 일일이 짰던 거였지?[^1]

[^1]: 글 쓰다가 기억났는데, 원래 저 부분의 소스는 C++가 아니라 **C언어**로 작성된 부분이었기 때문임
