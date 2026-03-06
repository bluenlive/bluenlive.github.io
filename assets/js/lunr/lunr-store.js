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
      {
        {% comment %} 1. 제목은 원본 그대로 표시합니다 {% endcomment %}
        "title": {{ doc.title | jsonify }},

        {% comment %} 2. 요약문에서 특수문자를 제거하여 '파묘' 등을 검색 가능하게 만듭니다 {% endcomment %}
        "excerpt":
          {%- if site.search_full_content == true -%}
            {{ doc.content | newline_to_br |
              replace:"<br />", " " | replace:"</p>", " " | replace:"</h1>", " " |
              replace:"</h2>", " " | replace:"</h3>", " " | replace:"</h4>", " " |
              replace:"</h5>", " " | replace:"</h6>", " "|
              strip_html | strip_newlines | 
              replace: '〈', ' ' | replace: '〉', ' ' | replace: '《', ' ' | replace: '》', ' ' | 
              replace: '(', ' ' | replace: ')', ' ' | replace: '[', ' ' | replace: ']', ' ' | 
              replace: '【', ' ' | replace: '】', ' ' | replace: ',', ' ' | replace: '.', ' ' | 
              replace: ':', ' ' | replace: '꞉', ' ' | replace: '/', ' ' | jsonify }},
          {%- else -%}
            {{ doc.content | newline_to_br |
              replace:"<br />", " " | replace:"</p>", " " | replace:"</h1>", " " |
              replace:"</h2>", " " | replace:"</h3>", " " | replace:"</h4>", " " |
              replace:"</h5>", " " | replace:"</h6>", " "|
              strip_html | strip_newlines | 
              replace: '〈', ' ' | replace: '〉', ' ' | replace: '《', ' ' | replace: '》', ' ' | 
              replace: '(', ' ' | replace: ')', ' ' | replace: '[', ' ' | replace: ']', ' ' | 
              replace: '【', ' ' | replace: '】', ' ' | replace: ',', ' ' | replace: '.', ' ' | 
              replace: ':', ' ' | replace: '꞉', ' ' | replace: '/', ' ' | 
              truncatewords: 50 | jsonify }},
          {%- endif -%}
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
  {
    "title": {{ doc.title | jsonify }},
    "excerpt":
        {%- if site.search_full_content == true -%}
          {{ doc.content | newline_to_br |
            replace:"<br />", " " | replace:"</p>", " " | replace:"</h1>", " " |
            replace:"</h2>", " " | replace:"</h3>", " " | replace:"</h4>", " " |
            replace:"</h5>", " " | replace:"</h6>", " "|
            strip_html | strip_newlines | 
            replace: '〈', ' ' | replace: '〉', ' ' | replace: '꞉', ' ' | replace: ':', ' ' | jsonify }},
        {%- else -%}
          {{ doc.content | newline_to_br |
            replace:"<br />", " " | replace:"</p>", " " | replace:"</h1>", " " |
            replace:"</h2>", " " | replace:"</h3>", " " | replace:"</h4>", " " |
            replace:"</h5>", " " | replace:"</h6>", " "|
            strip_html | strip_newlines | 
            replace: '〈', ' ' | replace: '〉', ' ' | replace: '꞉', ' ' | replace: ':', ' ' | 
            truncatewords: 50 | jsonify }},
        {%- endif -%},
    "url": {{ doc.url | absolute_url | jsonify }}
  }{%- unless forloop.last and l -%},{%- endunless -%}
  {%- endfor -%}
{%- endif -%}]