# _plugins/arrow_replacer.rb
Jekyll::Hooks.register :documents, :pre_render do |doc|
  next unless doc.extname == ".md"

  puts ">> [ArrowReplacer] Robust-Processing: #{doc.relative_path}"

  # 1. 보호 구역 격리 (Masking)
  # 코드 블록, 인라인 코드, HTML 주석, 수학 공식($$), Liquid 태그({% %})를 보호합니다.
  protected_items = []
  
  # 보호할 패턴 정의
  protection_regex = /(^```.*?^```|^~~~.*?^~~~|`.*?`||\$\$.*?\$\$|\{%.*?%\}|\{\{.*?\}\})/m

  doc.content = doc.content.gsub(protection_regex) do |match|
    # 마크다운 문법과 겹치지 않는 고유한 이름표 사용
    placeholder = "AR_SAFE_ZONE_#{protected_items.length}_"
    protected_items << match
    placeholder
  end

  # 2. 안전 구역 화살표 치환 (본문 텍스트만 남은 상태)
  # 사용자님의 본문에 있는 정확한 패턴들을 타겟팅합니다.
  doc.content.gsub!(/==\u003E/, ' ⟹ ')
  doc.content.gsub!(/(?:--|\u2013|\u2014)>/, ' ⟶ ')
  doc.content.gsub!(/(?:>>>|>>|\u00BB\u003E|\u00BB)/, ' ➤ ')

  # 3. 보호 구역 복구 (Unmasking)
  protected_items.each_with_index do |original_content, i|
    doc.content.gsub!("AR_SAFE_ZONE_#{i}_", original_content)
  end

  # 4. 제목(Title) 처리
  if doc.data['title']
    title = doc.data['title'].dup
    title.gsub!(/==\u003E/, ' ⟹ ')
    title.gsub!(/(?:--|\u2013|\u2014)>/, ' ⟶ ')
    title.gsub!(/(?:>>>|>>|\u00BB)/, ' ➤ ')
    doc.data['title'] = title
  end
end
