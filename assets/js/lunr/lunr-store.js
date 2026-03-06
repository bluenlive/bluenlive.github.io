---
layout: none
---

var store = [
  {%- for c in site.collections -%}
    {%- if forloop.last -%}
      {%- assign l = true -%}
    {%- endif -%}
    {%- assign docs = c.docs | where_exp:'doc','doc.search != false' -%}
    {%- for doc in docs -%}
      {%- if doc.header.teaser -%}
        {%- capture teaser -%}{{ doc.header.teaser }}{%- endcapture -%}
      {%- else -%}
        {%- assign teaser = site.teaser -%}
      {%- endif -%}

      {%- comment %} 1. 검색 엔진을 위한 '세탁된 제목' 생성 {% endcomment -%}
      {%- assign search_keywords = doc.title | 
        replace: '〈', ' ' | replace: '〉', ' ' | replace: '《', ' ' | replace: '》', ' ' | 
        replace: '(', ' ' | replace: ')', ' ' | replace: '[', ' ' | replace: ']', ' ' | 
        replace: '【', ' ' | replace: '】', ' ' | replace: ',', ' ' | replace: '.', ' ' | 
        replace: ':', ' ' | replace: '꞉', ' ' | replace: '/', ' ' -%}

      {
        {% comment %} 2. 화면 표시용: 원본 제목 그대로 유지 {% endcomment %}
        "title": {{ doc.title | jsonify }},
        
        {% comment %} 3. 요약문: 본문을 먼저 보여주고, 검색용 키워드는 맨 뒤에 추가 {% endcomment %}
        "excerpt":
          {%- capture combined_excerpt -%}
            {%- if site.search_full_content == true -%}
              {{ doc.content | newline_to_br |
                replace:"<br />", " " | replace:"</p>", " " | replace:"</h1>", " " |
                replace:"</h2>", " " | replace:"</h3>", " " | replace:"</h4>", " " |
                replace:"</h5>", " " | replace:"</h6>", " "|
                strip_html | strip_newlines }} {{ search_keywords }}
            {%- else -%}
              {{ doc.content | newline_to_br |
                replace:"<br />", " " | replace:"</p>", " " | replace:"</h1>", " " |
                replace:"</h2>", " " | replace:"</h3>", " " | replace:"</h4>", " " |
                replace:"</h5>", " " | replace:"</h6>", " "|
                strip_html | strip_newlines | truncatewords: 50 }} {{ search_keywords }}
            {%- endif -%}
          {%- endcapture -%}
          {{ combined_excerpt | jsonify }},

        "categories": {{ doc.categories | jsonify }},
        "tags": {{ doc.tags | jsonify }},
        "url": {{ doc.url | relative_url | jsonify }},
        "teaser": {{ teaser | relative_url | jsonify }}
      }{%- unless forloop.last and l -%},{%- endunless -%}
    {%- endfor -%}
  {%- endfor -%}{%- if site.lunr.search_within_pages -%},
  {%- assign pages = site.pages | where_exp: 'doc', 'doc.search != false' | where_exp: 'doc', 'doc.title != null' -%}
  {%- for doc in pages -%}
    {%- if forloop.last -%}
      {%- assign l = true -%}
    {%- endif -%}
    
    {%- assign page_keywords = doc.title | replace: '〈', ' ' | replace: '〉', ' ' | replace: '꞉', ' ' | replace: ':', ' ' -%}

  {
    "title": {{ doc.title | jsonify }},
    "excerpt":
      {%- capture page_excerpt -%}
        {%- if site.search_full_content == true -%}
          {{ doc.content | newline_to_br |
            replace:"<br />", " " | replace:"</p>", " " | replace:"</h1>", " " |
            replace:"</h2>", " " | replace:"</h3>", " " | replace:"</h4>", " " |
            replace:"</h5>", " " | replace:"</h6>", " "|
            strip_html | strip_newlines }} {{ page_keywords }}
        {%- else -%}
          {{ doc.content | newline_to_br |
            replace:"<br />", " " | replace:"</p>", " " | replace:"</h1>", " " |
            replace:"</h2>", " " | replace:"</h3>", " " | replace:"</h4>", " " |
            replace:"</h5>", " " | replace:"</h6>", " "|
            strip_html | strip_newlines | truncatewords: 50 }} {{ page_keywords }}
        {%- endif -%}
      {%- endcapture -%}
      {{ page_excerpt | jsonify }},
    "url": {{ doc.url | absolute_url | jsonify }}
  }{%- unless forloop.last and l -%},{%- endunless -%}
  {%- endfor -%}
{%- endif -%}]