# _plugins/arrow_replacer.rb
Jekyll::Hooks.register :documents, :pre_render do |doc|
  # 마크다운 파일이 아니면 건너뜁니다.
  next unless doc.extname == ".md"

  # 1. 원본 내용 백업 및 로그 출력
  content = doc.content
  puts ">> [ArrowReplacer] Analyzing: #{doc.relative_path} (#{content.length} chars)"

  # 2. 정규표현식 (유니코드 이스케이프 사용으로 인코딩 문제 차단)
  # \u2013: – (En-dash), \u2014: — (Em-dash), \u00BB: » (Double angle quote)
  # 기호 조합: -->, –>, —>, ==>, >>>, >>, »>, »
  regex = /(^```.*?^```|^~~~.*?^~~~|`.*?`|)|((?:--|\u2013|\u2014)>|==\u003E|(?:>>>|>>|\u00BB\u003E|\u00BB))/m

  # 3. 변환 수행 및 결과 로그 확인
  match_count = 0
  new_content = content.gsub(regex) do |match|
    if $1 # 무시 영역
      match
    else
      match_count += 1
      found = $2
      puts "   [Found] '#{found}' in #{doc.relative_path}" # 어떤 기호가 걸렸는지 로그로 확인
      
      case found
      when /--|\u2013|\u2014/ # 대시류 + >
        ' ⟶ '
      when /==\u003E/          # ==>
        ' ⟹ '
      when />>|\u00BB/         # >> 또는 »
        ' ➤ '
      else
        match
      end
    end
  end

  # 4. 변경 사항 적용
  if match_count > 0
    doc.content = new_content
    puts "   [Done] Replaced #{match_count} arrows."
  end
end
