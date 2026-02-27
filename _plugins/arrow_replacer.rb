# _plugins/arrow_replacer.rb
Jekyll::Hooks.register :documents, :pre_render do |doc|
  # 마크다운 파일만 처리
  next unless doc.extname == ".md"

  puts ">> [ArrowReplacer] Scanning: #{doc.relative_path}"
  
  # 정규표현식 보강: 대시류, 등호, 꺽쇠/인용구류를 모두 포함
  # \u2013(–), \u2014(—), \u00BB(»)
  regex = /(^```.*?^```|^~~~.*?^~~~|`.*?`|)|(==>|[--–—]{1,2}>|[>»]{2,3}>?|\u00BB)/m

  new_content = doc.content.gsub(regex) do |match|
    if $1 # 코드 블록이나 주석 영역
      match
    else
      found = $2
      # 어떤 기호를 찾았는지 로그에 찍습니다. (Actions 로그에서 확인 가능)
      puts "   [Match Found] '#{found}' in #{doc.relative_path}"
      
      case found
      when /==>/
        ' ⟹ '
      when /[--–—]{1,2}>/
        ' ⟶ '
      when /[>»]{2,3}/, "\u00BB"
        ' ➤ '
      else
        match
      end
    end
  end
  
  doc.content = new_content

  # 제목(Title) 처리
  if doc.data['title']
    doc.data['title'] = doc.data['title'].gsub(regex) { |m| $1 ? m : (m =~ /==>/ ? ' ⟹ ' : (m =~ /[--–—]/ ? ' ⟶ ' : ' ➤ ')) }
  end
end
