# _plugins/custom_markers.rb
Jekyll::Hooks.register :documents, :post_render do |doc|
  next unless doc.extname == ".md"

  # 1. 보호 블록 정의 (이 태그 내부의 내용은 절대 건드리지 않습니다)
  # pre, code, script, style, math 블록을 통째로 캡처하여 분리합니다.
  protected_block_regex = /(<(pre|code|script|style|math)[^>]*>.*?<\/\2>)/mi

  # 2. 전체 출력을 보호 블록 단위로만 쪼갭니다. (<a> 태그 등은 쪼개지 않고 일반 텍스트에 포함됨)
  doc.output = doc.output.split(protected_block_regex).map do |part|
    if part =~ protected_block_regex
      # 보호 구역이면 그대로 반환
      part
    else
      # 3. 일반 영역: 인라인 HTML 태그(<a> 등)가 포함된 상태에서 치환 수행
      res = part.dup
      
      # 4중 콜론 (comment) - /m 옵션을 주어 태그가 여러 줄에 걸쳐 있어도 대응
      res.gsub!(/(?<!:):{4}(?!:)(.+?)(?<!:):{4}(?!:)/m, '<span class="comment">\1</span>')
      
      # 3중 콜론 (desc)
      res.gsub!(/(?<!:):{3}(?!:)(.+?)(?<!:):{3}(?!:)/m, '<span class="desc">\1</span>')
      
      res
    end
  end.join

  # 제목(Title) 처리 (제목에는 보통 블록 태그가 없으므로 단순 치환)
  if doc.data['title']
    t = doc.data['title'].dup
    t.gsub!(/(?<!:):{4}(?!:)(.+?)(?<!:):{4}(?!:)/, '<span class="comment">\1</span>')
    t.gsub!(/(?<!:):{3}(?!:)(.+?)(?<!:):{3}(?!:)/, '<span class="desc">\1</span>')
    doc.data['title'] = t
  end
end