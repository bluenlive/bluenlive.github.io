---
layout: null
permalink: /assets/js/data/search.js
---

[
  {% for post in site.posts %}
  {
    "title": {{ post.title | jsonify }},
    "url": {{ post.url | relative_url | jsonify }},
    "categories": {{ post.categories | join: ', ' | jsonify }},
    "tags": {{ post.tags | join: ', ' | jsonify }},
    "date": {{ post.date | jsonify }},
    "content": {{ post.content | strip_html | strip_newlines | replace: ' ', ' ' | string_escape | jsonify }}
  }{% unless forloop.last %},{% endunless %}
  {% endfor %}
]
