# _plugins/arrow_replacer.rb
Jekyll::Hooks.register :documents, :pre_render do |doc|
  next unless doc.extname == ".md"

  # 1. 본문을 토큰 단위로 분할 (코드 블록, Liquid 태그, 인라인 코드 격리)
  # 정규표현식은 오직 '분리'를 위해서만 사용합니다.
  tokens = doc.content.split(/(^```.*?^```|\{%.*?%\}|\{\{.*?\}\}|`.*?`)/m)

  tokens.map! do |token|
    # 보호해야 할 패턴으로 시작하는 토큰은 건드리지 않고 그대로 반환
    if token.start_with?('```') || token.start_with?('{') || token.start_with?('`')
      token
    else
      # 2. 일반 텍스트 영역에서만 명시적으로 치환 (유니코드 대응 포함)
      res = token.dup
      res.gsub!('==>', ' ⟹ ')
      res.gsub!('-->', ' ⟶ ')      # 표준 대시
      res.gsub!("\u2013>", ' ⟶ ')  # En-dash (–>)
      res.gsub!("\u2014>", ' ⟶ ')  # Em-dash (—>)
      res.gsub!('>>>', ' ➤ ')
      res.gsub!('>>', ' ➤ ')
      res.gsub!("\u00BB>", ' ➤ ')  # »> 대응
      res.gsub!("\u00BB", ' ➤ ')   # » 대응
      res
    end
  end

  # 3. 토큰 재결합
  doc.content = tokens.join

  # 제목(Title) 처리 (제목은 구조가 단순하므로 직접 치환)
  if doc.data['title']
    t = doc.data['title'].dup
    t.gsub!('==>', ' ⟹ ')
    t.gsub!('-->', ' ⟶ ')
    t.gsub!("\u2013>", ' ⟶ ')
    t.gsub!('>>>', ' ➤ ')
    t.gsub!('>>', ' ➤ ')
    t.gsub!("\u00BB", ' ➤ ')
    doc.data['title'] = t
  end
end
