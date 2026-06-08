---
title: "farewell"
layout: archive
permalink: /farewell
---


{% assign posts = site.categories.farewell %}
{% for post in posts %} {% include archive-single.html type=page.entries_layout %} {% endfor %}
