---
layout: single
title: "깃허브 블로그 개설 과정"
categories:
  - blog
toc: true
toc_label: "Contents"
#toc_icon: "cog"
toc_icon: "book-open"
toc_sticky: true
---

깃허브에 블로그를 개설하는 과정은 다른 블로그에 비해 쉬운 편은 아니다.  
은근 알아야 할 것들도 많고, 일일이 다 설명하기 어려운 부분들도 있다.

블로그를 개설, 설정하는 과정을 간략하게 정리해둔다.  
모든 과정을 상세히 기록하지 않고, 실제 블로그 개설 과정에서 참고했던 글들을 링크해둔다.

## 1. 깃허브 블로그 개설

깃허브 블로그를 개설하는 방법은 여러 가지가 있다.  
Ruby와 Jekyll을 설치하여 로컬에서 블로그를 개발한 뒤, 깃허브에 올리는 방법이 제일 정석적인 방법인 것 같다.  
또는, 사용할 테마를 리모트로 지정하여 블로그를 개설하는 방법도 있다.

나는 간단하게 **Minimal Mistakes** 테마를 fork하여 블로그를 개설했다.  
세부 절차는 아래 유튜브 영상을 참고.

{% include bluenlive/youtube.html id="--MMmHbSH9k" %}

## 2. 테마 및 디자인 설정

테마를 fork하여 블로그를 개설하면, 기본적인 디자인은 일단 완성된 상태이다.  
하지만, 너무 기본만 되어있고, 손을 좀 더 대야 할 필요가 있다.

### 2.1. _config.yml 설정

스킨의 설정은 대부분 `_config.yml` 파일에서 이루어진다.  
스킨 테마부터 여기서 설정.

기본적으로 글을 읽는데 소요되는 시간을 표시하는데, 이게 좀 불편하다.  
이를 해결하기 위해서는 `_config.yml` 파일에서 `read_time` 항목을 `false`로 수정하면 된다.  
더불어 여기에 글의 작성 일시를 표시하려면 같은 자리에 `show_date` 항목을 `true`로 기록하면 된다.  

### 2.2. 파비콘, 카테고리, 글꼴, 여백 설정

파비콘은 [이 글](https://velog.io/@eona1301/Github-Blog-%ED%8C%8C%EB%B9%84%EC%BD%98Favicon-%EC%84%B8%ED%8C%85%ED%95%98%EA%B8%B0){:target="_blank"}을 참조했다.  
내용을 추가해야 하는 파일의 위치는 `_includes\_head\custom.html`.

카테고리와 태그를 사용하기 위해서는 `_data\navigation.yml` 파일을 수정해야 한다.  
그리고, `_pages\categories.md`와 `_pages\tags.md` 파일 등의 이름으로 파일을 생성해야 한다.  
세부 내용은 [본진](https://mmistakes.github.io/minimal-mistakes/docs/helpers/#navigation-list){:target="_blank"}, [이 글](https://devinlife.com/howto%20github%20pages/category-tag/){:target="_blank"}, [이 글](https://honbabzone.com/jekyll/start-gitHubBlog/){:target="_blank"}, [이 글](https://x2info.github.io/minimal-mistakes/%EC%B9%B4%ED%85%8C%EA%B3%A0%EB%A6%AC_%EB%A7%8C%EB%93%A4%EA%B8%B0/){:target="_blank"}, [이 글](https://x2info.github.io/minimal-mistakes/%EC%B9%B4%ED%85%8C%EA%B3%A0%EB%A6%AC_%ED%8F%AC%EC%8A%A4%ED%8A%B8%EC%88%98_%EC%B6%9C%EB%A0%A5/){:target="_blank"} 등을 참조.

메뉴에 드롭다운 기능을 구현했는데, [이 글](https://github.com/mmistakes/minimal-mistakes/issues/1801){:target="_blank"}을 참고했다.

글꼴, 본문 여백 등은 `_sass\minimal-mistakes\_variables.scss` 파일에서 수정하면 된다.  
`@import`로 글꼴을 추가할 수도 있고, `$right-sidebar-width` 변수를 수정해서 여백도 조절 가능.

글자 크기는 `_sass\minimal-mistakes\_reset.scss` 파일에서 수정하면 된다.

검색창 기능은 [이 글](https://mmistakes.github.io/minimal-mistakes/docs/configuration/#site-search){:target="_blank"}을 참조했다.  
내 블로그만 검색하거나 인터넷을 검색하는 선택을 할 수 있는데, 내 블로그만 검색하는 것을 선택.

## 3. 그 외의 기능 설정

### 3.1. 구글 애널리틱스과 구글 애드센스

구글 애널리틱스를 사용하려면, `_config.yml` 파일에서 `analytics` 항목을 수정해야 한다.  
[이 글](https://www.openads.co.kr/content/contentDetail?contsId=10093){:target="_blank"}을 참조.

구글 애드센스 적용은 [이 글](https://junhyunny.github.io/information/minimal-mistakes-adsense/){:target="_blank"}을 참조했다.  
작업 중에 **싱가포르의 세금 정보**(싱가포르에 거주하지 않는다는 증명)를 입력하라는 메시지를 봐서 처리함.

### 3.2. 구글 검색에서 검색 가능하도록 설정

[이 글](https://x2info.github.io/minimal-mistakes/%EA%B5%AC%EA%B8%80_%EB%B8%94%EB%A1%9C%EA%B7%B8_%EC%B6%94%EA%B0%80/){:target="_blank"}, [이 글](https://here-now-flow.tistory.com/entry/GitHub-Pages-Jekyll-%EB%B8%94%EB%A1%9C%EA%B7%B8-%EC%8B%9C%EC%9E%91%ED%95%98%EA%B8%B04-%EB%B8%94%EB%A1%9C%EA%B7%B8-%EA%B5%AC%EA%B8%80-%EA%B2%80%EC%83%89-%EB%85%B8%EC%B6%9C-%EC%8B%9C%ED%82%A4%EA%B8%B0Google-Search-Console){:target="_blank"}을 참조했다.

### 3.3 수식 표시 기능

[이 글](https://ansohxxn.github.io/blog/math-equation/){:target="_blank"}을 참조해서 적용할 예정.

### 3.4 댓글 기능

Giscus를 사용하는 것이 합리적이라 판단. [이 글](https://univdev.page/posts/add-giscus/){:target="_blank"} 및 [이 글](https://devshjeon.github.io/78){:target="_blank"}을 참고함.

### 3.5 자체 도메인 사용

[이 글](https://wonderbout.tistory.com/120){:target="_blank"}과 [이 글](https://mishka.kr/12){:target="_blank"}을 참고함.

## 4. 포스팅 관련

이미지 갤러리를 사용하는 것은 [이 글](https://mmistakes.github.io/minimal-mistakes/post%20formats/post-gallery/){:target="_blank"}을 참고했다.  
간단히 요약하면, 헤더 영역에 gallery 목록을 작성하고, 본문에는 다음 형식으로 갤러리를 삽입.

```liquid
{% raw %}{% include gallery id="gallery_name" %}{% endraw %}
```

이미지를 깃허브에 직접 올리지 않고, **구글 드라이브나 원 드라이브에 올리는 방법은 현재 적용이 불가능**함.  
실제로 적용해보면 이미지가 화면에 표시되지 않는다.

포스팅을 하려면 `_posts` 폴더에 `yyyy-mm-dd-title.md` 형식으로 **markdown** 파일을 생성하면 된다.  
유의사항: 이 날짜는 **UTC 기준**으로, **오전 9시 이전엔 전일 날짜**를 써야만 정상적으로 블로그에 표시됨.  
포스팅 어플은 기존에 사용하던 [Visual Studio Code](https://code.visualstudio.com/){:target="_blank"}를 사용.

![image](/images/2024-01-18/githubblog.png){: .align-center}

## 5. 기타

Minimal Mistakes 테마의 디렉토리 구조는 [이 글](https://jiwanm.github.io/blog/jekyll-directory-structure/){:target="_blank"}을 참고하면 된다.
