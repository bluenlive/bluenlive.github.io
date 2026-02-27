# _plugins/arrow_replacer.rb
Jekyll::Hooks.register :documents, :pre_render do |doc|
  next unless doc.extname == ".md"

  # 현재 처리 중인 파일 로그
  puts ">> [ArrowReplacer] Target: #{doc.relative_path}"

  # 변환 전 원본 보관
  original = doc.content.dup

  # 1. 등호 화살표 (가장 안전)
  doc.content.gsub!('==>', ' ⟹ ')

  # 2. 대시 화살표 (SmartyPants가 바꾼 특수 대시 – 포함)
  # 일반 대시(-->), 긴 대시(–>), 더 긴 대시(—>) 모두 대응
  doc.content.gsub!(/(--|\u2013|\u2014)>/, ' ⟶ ')

  # 3. 꺽쇠 화살표 (SmartyPants가 바꾼 » 포함)
  # >>>, >>, »>, » 모두 대응
  doc.content.gsub!(/(>>>|>>|\u00BB>|\u00BB)/, ' ➤ ')

  # 치환 결과 확인 로그
  if original != doc.content
    puts "   [Success] Arrows replaced in #{doc.relative_path}"
  end

  # 제목도 동일하게 처리
  if doc.data['title']
    doc.data['title'].gsub!(/(--|\u2013|\u2014)>/, ' ⟶ ')
    doc.data['title'].gsub!('==>', ' ⟹ ')
    doc.data['title'].gsub!(/(>>>|>>|\u00BB)/, ' ➤ ')
  end
end
