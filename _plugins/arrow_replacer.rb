# _plugins/arrow_replacer.rb
Jekyll::Hooks.register :documents, :pre_render do |doc|
  next unless doc.extname == ".md"

  puts ">> [ArrowReplacer] Safe-Processing: #{doc.relative_path}"

  # 1. 보호 구역 격리 (Masking)
  # 코드 블록, 인라인 코드, 주석을 찾아 순서대로 배열에 저장하고 본문에서는 임시 표커로 대체합니다.
  protected_blocks = []
  doc.content = doc.content.gsub(/(^```.*?^```|^~~~.*?^~~~|`.*?`|)/m) do |match|
    placeholder = "##BLOCK_#{protected_blocks.length}##"
    protected_blocks << match
    placeholder
  end

  # 2. 안전 구역 화살표 치환 (수치가 검증된 로직)
  # 이제 본문에는 '진짜 텍스트'만 남았으므로 안심하고 치환합니다.
  doc.content.gsub!(/==\u003E/, ' ⟹ ')
  doc.content.gsub!(/(?:--|\u2013|\u2014)>/, ' ⟶ ')
  doc.content.gsub!(/(?:>>>|>>|\u00BB\u003E|\u00BB)/, ' ➤ ')

  # 3. 보호 구역 복구 (Unmasking)
  protected_blocks.each_with_index do |block, i|
    doc.content.gsub!("##BLOCK_#{i}##", block)
  end

  # 제목(Title) 처리 (제목에는 코드 블록이 올 일이 거의 없으므로 단순 치환)
  if doc.data['title']
    title = doc.data['title']
    title.gsub!(/==\u003E/, ' ⟹ ')
    title.gsub!(/(?:--|\u2013|\u2014)>/, ' ⟶ ')
    title.gsub!(/(?:>>>|>>|\u00BB)/, ' ➤ ')
    doc.data['title'] = title
  end
end
