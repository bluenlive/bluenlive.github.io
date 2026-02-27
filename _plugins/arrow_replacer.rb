Jekyll::Hooks.register [:posts, :pages], :pre_render do |doc|
  # 1. 화살표 변환 정규표현식
  # 무시할 영역(코드 블록, 주석 등)을 먼저 캡처하고, 변환할 화살표를 뒤에 배치합니다.
  regex = /(^```.*?^```|^~~~.*?^~~~|`.*?`|)|(==>|-->|>>)/m

  # 2. 치환 로직 정의 (중복 방지를 위한 람다 함수)
  replacer = lambda do |text|
    return text if text.nil?
    text.gsub(regex) do |match|
      if $1 # 무시 영역에 해당하면 그대로 반환
        match
      else
        case $2
        when '-->' then ' ⟶ '
        when '==>' then ' ⟹ '
        when '>>'  then ' ➤ '
        else match
        end
      end
    end
  end

  # 3. [본문 적용] 헤드라인, 각주, 이미지 설명 등이 모두 포함됩니다.
  doc.content = replacer.call(doc.content)

  # 4. [메타데이터 적용] 제목(title) 등 Front Matter에 정의된 필드들
  if doc.data['title']
    doc.data['title'] = replacer.call(doc.data['title'])
  end
  
  # 만약 부제목(subtitle)이나 요약(excerpt)도 쓰신다면 아래처럼 추가 가능합니다.
  if doc.data['excerpt']
    doc.data['excerpt'] = replacer.call(doc.data['excerpt'].to_s)
  end
end
