---
layout: single
title: "TinyEmmet 테스트 케이스 목록"
date: 2026-6-18 18:18:00 +0900
categories:
  - ITTalk
tags: []
---

새로 구축한 TinyEmmet 엔진의 무결성을 검증하기 위해 돌렸던 HTML, XML, CSS 프로파일별 최종 테스트 명세 기록이다.

---

## 1. HTML / XHTML 프로파일 테스트

공태그 마감 처리(`/>`), 불리언 속성 최적화, 콜론(`:`) 확장 동의어 매핑, 플레이스홀더 클리닝 메커니즘을 동시 검증함.

### 성공 케이스 (10개)

#### ① 기본 하이퍼링크 및 메일 약어

* **입력 식:** `a:link+a:mail`
* **HTML5 / XHTML 공통 결과:**

```html
<a href="http://"></a><a href="mailto:"></a>
```

#### ② 외부 자원 연결 및 플레이스홀더 제거

* **입력 식:** `head>link:css+script:src`
* **HTML5 결과:**

```html
<head>
	<link rel="stylesheet" type="text/css" href="style.css" media="all">
	<script src=""></script>
</head>
```

* **XHTML 결과:**

```html
<head>
	<link rel="stylesheet" type="text/css" href="style.css" media="all" />
	<script src=""></script>
</head>
```

#### ③ 문서 메타데이터 공태그 명세

* **입력 식:** `meta:utf+meta:vp`
* **HTML5 결과:**

```html
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

* **XHTML 결과:**

```html
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
```

#### ④ 폼 제어 및 콜론 풀네임 동의어 매핑

* **입력 식:** `form>input:text+input:hidden`
* **HTML5 결과:**

```html
<form action="">
	<input type="text" name="" id="">
	<input type="hidden" name="">
</form>
```

* **XHTML 결과:**

```html
<form action="">
	<input type="text" name="" id="" />
	<input type="hidden" name="" />
</form>
```

#### ⑤ 폼 컨트롤 다중 속성 및 불리언 처리

* **입력 식:** `input:checkbox[checked]+input:password[required]`
* **HTML5 결과:**

```html
<input type="checkbox" name="" id="" checked><input type="password" name="" id="" required>
```

* **XHTML 결과:**

```html
<input type="checkbox" name="" id="" checked="checked" /><input type="password" name="" id="" required="required" />
```

#### ⑥ 사용자 명시적 속성값 보존 규칙

* **입력 식:** `input:radio[checked=true]`
* **HTML5 결과:**

```html
<input type="radio" name="" id="" checked="true">
```

* **XHTML 결과:**

```html
<input type="radio" name="" id="" checked="true" />
```

#### ⑦ 멀티미디어 불리언 복합 제어

* **입력 식:** `video[autoplay controls loop]>source`
* **HTML5 결과:**

```html
<video autoplay controls loop>
	<source src="" type="">
</video>
```

* **XHTML 결과:**

```html
<video autoplay="autoplay" controls="controls" loop="loop">
	<source src="" type="" />
</video>
```

#### ⑧ 스크립트 비동기/지연 속성 결합

* **입력 식:** `script[src=main.js async defer]`
* **HTML5 결과:**

```html
<script src="main.js" async defer></script>
```

* **XHTML 결과:**

```html
<script src="main.js" async="async" defer="defer"></script>
```

#### ⑨ 계층 구조형 확장 지시어 결합 (`table+`)

* **입력 식:** `table+>thead>tr>th*2`
* **HTML5 / XHTML 공통 결과:**

```html
<table>
	<tr>
		<td>
			<thead>
				<tr>
					<th></th>
					<th></th>
				</tr>
			</thead>
		</td>
	</tr>
</table>
```

※ *의도된 스트레스 테스트 구문임. table+ 명세가 뿜어낸 내부 td 격리 공간을 엔진이 깨짐 없이 파싱하는지 검증함.*

#### ⑩ 암묵적 명칭 유추 및 블록 노드 들여쓰기 보정

* **입력 식:** `#page>.logo+ul.nav>li*2>.item`
* **HTML5 / XHTML 공통 결과:**

```html
<div id="page">
	<div class="logo"></div>
	<ul class="nav">
		<li>
			<div class="item"></div>
		</li>
		<li>
			<div class="item"></div>
		</li>
	</ul>
</div>
```

---

### 방어 / 예외 케이스 (2개)

#### ⑪ 미등록 콜론 약어 처리 방어

* **입력 식:** `div>input:invalid-spec`
* **공통 결과:**

```html
<div><input:invalid-spec></input:invalid-spec></div>
```

※ *사전에 없는 가짜 약어라도 크래시 없이 무명 커스텀 태그로 소화함.*

#### ⑫ 닫는 대괄호 누락 문법 파괴 방어

* **입력 식:** `input[type=text name=id`
※ *속성 분석 범위 오류(npos) 예외 트랙을 타고 파싱을 안전하게 중단하여 전체 엔진 크래시를 원천 봉쇄함.*

---

## 2. XML 프로파일 테스트

웹 표준 지정 공태그 명세에 의존하지 않고, 자식과 본문이 비어있는 모든 요소를 엄격하게 축약(`<tag />`)하는지 검증한다.

### 성공 케이스 (10개)

#### ① 빈 컨테이너 태그의 일괄 축약

* **입력 식:** `user>name+age+gender`
* **XML 결과:**

```xml
<user>
	<name />
	<age />
	<gender />
</user>
```

#### ② 속성을 포함한 엘리먼트 축약

* **입력 식:** `item[id=001 class=goods]`
* **XML 결과:**

```xml
<item id="001" class="goods" />
```

#### ③ 데이터 콘텐츠가 존재하는 노드의 태그 쌍 유지

* **입력 식:** `response>status{200}+message{SUCCESS}`
* **XML 결과:**

```xml
<response>
	<status>200</status>
	<message>SUCCESS</message>
</response>
```

#### ④ 다중 계층 데이터 트리 생성

* **입력 식:** `bookstore>book*2>title+author`
* **XML 결과:**

```xml
<bookstore>
	<book>
		<title />
		<author />
	</book>
	<book>
		<title />
		<author />
	</book>
</bookstore>
```

#### ⑤ XML 속성값 엄격 바인딩 (축약 금지)

* **입력 식:** `node[visible]`
* **XML 결과:**

```xml
<node visible="" />
```

※ *불리언 속성이라도 대입연산 쌍을 강제 빌드함.*

#### ⑥ 커스텀 네임스페이스 모사 태그 전개

* **입력 식:** `maven>dependency>groupId+artifactId+version`
* **XML 결과:**

```xml
<maven>
	<dependency>
		<groupId />
		<artifactId />
		<version />
	</dependency>
</maven>
```

#### ⑦ 수치 반복 연산자를 통한 노드 생성

* **입력 식:** `record>field*3`
* **XML 결과:**

```xml
<record>
	<field />
	<field />
	<field />
</record>
```

#### ⑧ 중괄호 내 특수기호 보호 격리

* **입력 식:** `rss>channel>title{TEUS}+link{https://teus.me}`
* **XML 결과:**

```xml
<rss>
	<channel>
		<title>TEUS</title>
		<link>https://teus.me</link>
	</channel>
</rss>
```

#### ⑨ 형제 연산자 및 부모 복귀 연산자(`^`) 동시 제어

* **입력 식:** `root>header>id^content>body`
* **XML 결과:**

```xml
<root>
	<header>
		<id />
	</header>
	<content>
		<body />
	</content>
</root>
```

#### ⑩ 암묵적 태그명의 XML 디폴트 바인딩

* **입력 식:** `#catalog>.product*2`
* **XML 결과:**

```xml
<div id="catalog">
	<div class="product" />
	<div class="product" />
</div>
```

---

### 방어 / 예외 케이스 (2개)

#### ⑪ 값 지정 중 특수 기호 오인 가드

* **입력 식:** `node[query=a>b]`
※ *대괄호 문맥 내부의 꺾쇠(`>`)를 계층 연산자로 오인하지 않고 안전하게 격리함.*

#### ⑫ 비정상적인 반복 횟수 명세 방어

* **입력 식:** `item*abc` 또는 `item*-5`
※ *ParseInt 가드가 작동하여 오작동 수치를 1로 리셋, 단일 `<item />` 노드만 방어 출력함.*

---

## 3. CSS 프로파일 테스트

마크업 트리를 차단하고 전용 파이프라인 드라이버로 구동된다. 단위 변환, 샵 기호 자동 확장, 에러 제어 복구를 검증한다.

### 성공 케이스 (10개)

#### ① 고정식 단축어 룩업

* **입력 식:** `pos:a+d:f+fl:l`
* **CSS 결과:**

```css
position: absolute;
display: flex;
float: left;
```

#### ② 동적 수치 결합형 및 기본 px 단위 주입

* **입력 식:** `w100+h250+m20`
* **CSS 결과:**

```css
width: 100px;
height: 250px;
margin: 20px;
```

#### ③ 하이픈(-) 세퍼레이터를 통한 다중 수치 전개

* **입력 식:** `m10-20-30-40`
* **CSS 결과:**

```css
margin: 10px 20px 30px 40px;
```

#### ④ 패딩 방향별 정밀 수치 결합

* **입력 식:** `pt5+pr10+pb15+pl20`
* **CSS 결과:**

```css
padding-top: 5px;
padding-right: 10px;
padding-bottom: 15px;
padding-left: 20px;
```

#### ⑤ 단위 별칭(`p`, `e`, `r`)의 표준 단위 변환

* **입력 식:** `w50p+fs1.2e+m2r`
* **CSS 결과:**

```css
width: 50%;
font-size: 1.2em;
margin: 2rem;
```

#### ⑥ 샵 기호 유무 통합 색상 확장

* **입력 식:** `cfff` 또는 `cf`
* **CSS 결과:**

```css
color: #fff;
```

※ *보정된 헥사 가드가 샵 기호 기입 여부와 상관없이 동일한 축약형태를 감지함.*

#### ⑦ 복합 색상 코드의 6자리 지능형 자동 정렬

* **입력 식:** `bgc3f`
* **CSS 결과:**

```css
background-color: #33ffff;
```

#### ⑧ 단위 생략형 특수 정수 속성 가동

* **입력 식:** `z10+op0.5`
* **CSS 결과:**

```css
z-index: 10;
opacity: 0.5;
```

#### ⑨ 일반 문자 키워드 변환 (`a` $\rightarrow$ `auto`)

* **입력 식:** `w:a+m:a` 또는 `wa+ma`
* **CSS 결과:**

```css
width: auto;
margin: auto;
```

#### ⑩ 소수점 포함 음수 레이아웃 전개

* **입력 식:** `ml-15.5+top-.5e`
* **CSS 결과:**

```css
margin-left: -15.5px;
top: -.5em;
```

---

### 방어 / 예외 케이스 (2개)

#### ⑪ 비표준 문자(콤마) 조우 시 원본 복구 방어

* **입력 식:** `w100,h200`
* **예상 결과:**

```css
width: 100,h200
```

※ *에러 가드가 켜지는 즉시, 그 기점부터 남은 원본 식 전체를 그대로 보존 출력함.*

#### ⑫ 후속 토큰 복합 체인 연결 중 에러 크래시 방어

* **입력 식:** `w100+h200,invalid+opacity:1`
* **예상 결과:**

```css
width: 100px;
height: 200,invalid+opacity:1
```
