# _plugins/arrow_replacer.rb
Jekyll::Hooks.register :documents, :pre_render do |doc|
  next unless doc.extname == ".md"

  puts ">> [ArrowReplacer] One-Pass Scanning: #{doc.relative_path}"

  # [보호 구역] | [치환 대상] 을 한 번에 잡는 정규표현식
  # 1번 그룹 ($1): ```, ~~~, `, , {% %}, {{ }} (보호해야 할 영역)
  # 2번 그룹 ($2): ==>, -->, –>, —>, >>>, >>, »>, » (치환해야 할 영역)
  regex = %r{(```.*?```|~~~.*?~~~|`.*?`||\{%.*?%\}|\{\{.*?\}\})|(==>|[--–—]{1,2}>|[>»]{2,3}>?|\u00BB)}m

  new_content = doc.content.gsub(regex) do |match|
    if $1 # 1번 그룹(보호 구역)에 걸렸다면?
      match # 아무것도 건드리지 않고 그대로 반환
    elsif $2 # 2번 그룹(치환 대상)에 걸렸다면?
      case $2
      when /==>/
        ' ⟹ '
      when /[--–—]{1,2}>/
        ' ⟶ '
      when /[>»]{2,3}>?/, "\u00BB"
        ' ➤ '
      else
        match
      end
    else
      match
    end
  end

  # 변경 사항이 있을 때만 적용
  if doc.content != new_content
    doc.content = new_content
    puts "   [ArrowReplacer] Success! Replaced arrows in #{doc.relative_path}"
  end

  # 제목(Title) 처리 (제목에는 코드 블록이 없으므로 단순 치환)
  if doc.data['title']
    doc.data['title'] = doc.data['title'].gsub(regex) { |m| $1 ? m : (m =~ /==>/ ? ' ⟹ ' : (m =~ /[--–—]/ ? ' ⟶ ' : ' ➤ ')) }
  end
end
