---
layout: single
title: "블로그 내부 구성 보강"
categories:
  - blog
---

본 블로그는 [깃허브](https://github.com){:target="_blank"}의 **깃허브 페이지** 서비스에서 돌아간다.\
이 서비스는 알려져있다시피 Kramdown을 이용하여 Markdown 형식의 데이터를 HTML로 생성하는 방식이다.

`<div>` 등의 html 태그도 쓸 수 있고, 지금까지 태그를 적극적으로 사용해왔었다.\
하지만, 이제 2년 쯤 되어가니 태그를 직접 쓰지 않고 통일감 있는 스타일로 정리할 때가 되었다.

이번에 수정한 부분은 아래와 같다.

{: .bluebox-blue}
- 색상 박스 스타일 재구성하여 통일 및 색상 기준으로 이름 붙임
- 용도별 박스 스타일 재구성하여 통일
- 용도별 박스는 `Liquid`로 구현하여 소스 가독성 증대
- 인용구 박스, 다운로드 박스 역시 `Liquid`로 구현
- AI 질문 답별 박스 별도 스타일 지정하고 `Liquid`로 구현
- Postit 효과 박스 `Liquid`로 구현
- Youtube Embedded 영역은 순정의 `{% raw %}{% include video %}{% endraw %}`로 변환
