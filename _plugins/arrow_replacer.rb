# _plugins/arrow_replacer.rb
Jekyll::Hooks.register :documents, :pre_render do |doc|
  # 로그 출력: GitHub Actions 'Build with Jekyll' 단계에서 이 문구가 보여야 합니다.
  puts "Checking arrows in: #{doc.relative_path}"

  # 1. 무시할 영역: 코드 블록, 인라인 코드, HTML 주석
  # 2. 변환할 영역: 
  #    - [단일/특수 대시들] + > : (--, –, —)>
  #    - [등호] + > : ==>
  #    - [꺽쇠/인용부호] + > : (>>>, »>, >>, »)
  regex = /(^```.*?^```|^~~~.*?^~~~|`.*?`|)|((?:--|\u2013|\u2014)>|==>|(?:>>>|»>|>>|\u00BB))/m

  doc.content = doc.content.gsub(regex) do |match|
    if $1 # 코드 블록이나 주석 안이면 무시
      match
    else
      case $2
      when /[--–—]{1,2}>/      then '⟶'
      when '==>'               then '⟹'
      when /[>»]{2,3}/, "\u00BB" then '➤' # >> 나 » 기호 모두 대응
      else match
      end
    end
  end

  # 제목(Title) 필드도 별도로 한 번 더 처리
  if doc.data['title']
    doc.data['title'] = doc.data['title'].gsub(regex) do |m|
      $1 ? m : (m =~ /==>/ ? '⟹' : (m =~ /--/ ? '⟶' : '➤'))
    end
  end
end
