---
layout: single
title: "삭제할 내용 테스트"
date: 2025-12-02 08:00:00 +0900
categories:
  - MyProgram
---

삭제할 내용입니다

{% include bluenlive/quote.html
   align="center"
   author="hello"
   content='["They call me…", "Mister Tiibs", "추가 줄도 가능"]' %}

---

{% include bluenlive/quote.html
   author="hello"
   content='["They call me…", "Mister Tiibs", "추가 줄도 가능"]' %}

---

{% include bluenlive/quote.html
   align="left"
   content='한 줄만 써보자' %}

---

<div class="quoteMachine">
  <div class="theQuote">
    <blockquote><span class="quotationMark quotationMark--left"></span>
They call me&hellip;<br /> Mister Tiibs / 가운데 정렬
    <span class="quotationMark quotationMark--right"></span></blockquote>
  </div>
  <div class="quoteAuthor">
    - hello / 누가 썼는지 표기
  </div>
</div>

<div class="quoteMachine">
  <div class="theQuoteLeft">
    <blockquote><span class="quotationMark quotationMark--left"></span>
They call me&hellip;<br /> Mister Tiibs / 왼쪽 정렬
    <span class="quotationMark quotationMark--right"></span></blockquote>
  </div>
  <div class="quoteAuthor">
    - hello / 누가 썼는지 표기
  </div>
</div>

<div class="quoteMachine">
  <div class="theQuoteLeft">
    <blockquote><span class="quotationMark quotationMark--left"></span>
They call me&hellip;<br /> Mister Tiibs / 누가 썼는지 표기하지 않고 왼쪽 정렬
    <span class="quotationMark quotationMark--right"></span></blockquote>
  </div>
</div>
