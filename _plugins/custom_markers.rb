# _plugins/custom_markers.rb
Jekyll::Hooks.register :documents, :post_render do |doc|
  next unless doc.extname == ".md"

  # 1. 보호 블록 정의 (비캡처 그룹 ?: 을 사용하여 태그 이름 유출 방지)
  # <a> 태그 등 인라인 태그는 쪼개지 않고 통째로 처리하기 위해 블록 태그만 지정합니다.
  protected_block_regex = /(<(?:pre|code|script|style|math)[^>]*>.*?<\/(?:pre|code|script|style|math)>)/mi

  # 2. 전체 출력을 보호 블록 단위로 쪼개어 처리
  doc.output = doc.output.split(protected_block_regex).map do |part|
    if part =~ protected_block_regex
      # <pre>나 <script> 등 보호 구역은 그대로 반환
      part
    else
      # 일반 영역에서만 :::(desc)와 :::: (desc_comment) 치환
      res = part.dup
      
      # 4중 콜론 (desc_comment)
      res.gsub!(/(?<!:):{4}(?!:)(.+?)(?<!:):{4}(?!:)/m, '<span class="desc_comment">\1</span>')
      
      # 3중 콜론 (desc)
      res.gsub!(/(?<!:):{3}(?!:)(.+?)(?<!:):{3}(?!:)/m, '<span class="desc">\1</span>')
      
      res
    end
  end.join

  # 제목(Title) 처리
  if doc.data['title']
    t = doc.data['title'].dup
    t.gsub!(/(?<!:):{4}(?!:)(.+?)(?<!:):{4}(?!:)/, '<span class="desc_comment">\1</span>')
    t.gsub!(/(?<!:):{3}(?!:)(.+?)(?<!:):{3}(?!:)/, '<span class="desc">\1</span>')
    doc.data['title'] = t
  end
end