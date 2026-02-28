# _plugins/custom_emphasis.rb
Jekyll::Hooks.register :documents, :pre_render do |doc|
  next unless doc.extname == ".md"

  # 1. 보호 구역 격리 (Masking)
  # 코드 블록, 인라인 코드, HTML 주석, 수학 공식($$), Liquid 태그 등을 보호함
  protected_items = []
  protection_regex = /(^```.*?^```|^~~~.*?^~~~|`.*?`||\$\$.*?\$\$|\{%.*?%\}|\{\{.*?\}\})/m

  doc.content = doc.content.gsub(protection_regex) do |match|
    placeholder = "CE_SAFE_ZONE_#{protected_items.length}_"
    protected_items << match
    placeholder
  end

  # 2. 커스텀 강조 규칙 적용 (Kramdown의 엄격한 규칙 모사)
  
  # [규칙 1] __double__ -> <span class="comment">
  # - 조건: 앞이 공백/줄시작이고 뒤가 공백/구두점/줄끝이어야 함 (Intra-word 방지)
  # - 조건: 시작 직후와 종료 직전은 공백이 아니어야 함 (__ word __ 는 무효)
  double_regex = /(?<=^|\s)__(?=\S)(.+?)(?<=\S)__(?=$|\s|[.,!?;:])/
  doc.content.gsub!(double_regex) do
    content = $1
    "<span class=\"comment\">#{content}</span>"
  end

  # [규칙 2] _single_ -> <span class="desc">
  # - 조건: 위와 동일하며, 반드시 더블 언더스코어 처리 후에 실행되어야 함
  single_regex = /(?<=^|\s)_(?=\S)(.+?)(?<=\S)_(?=$|\s|[.,!?;:])/
  doc.content.gsub!(single_regex) do
    content = $1
    "<span class=\"desc\">#{content}</span>"
  end

  # 3. 보호 구역 복구 (Unmasking)
  protected_items.each_with_index do |original_content, i|
    doc.content.gsub!("CE_SAFE_ZONE_#{i}_", original_content)
  end

  # 제목(Title) 처리 - 제목은 보통 구조가 단순하므로 직접 처리
  if doc.data['title']
    title = doc.data['title'].dup
    title.gsub!(double_regex) { "<span class=\"comment\">#{$1}</span>" }
    title.gsub!(single_regex) { "<span class=\"desc\">#{$1}</span>" }
    doc.data['title'] = title
  end
end
