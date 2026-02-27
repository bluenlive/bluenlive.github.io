Jekyll::Hooks.register :documents, :pre_render do |doc|
  # 1. 무시할 영역: 코드 블록, 인라인 코드, HTML 주석
  # 2. 변환할 영역: (일반대시-- 또는 특수대시– 또는 —) + > 조합을 모두 찾음
  regex = /(^```.*?^```|^~~~.*?^~~~|`.*?`|)|((?:--|\u2013|\u2014)>|==>|>>>)/m

  replacer = lambda do |text|
    return text if text.nil?
    text.gsub(regex) do |match|
      if $1 # 무시 영역
        match
      else
        # 매칭된 기호에 따라 변환
        case $2
        when /(--|\u2013|\u2014)>/ then ' ⟶ ' # 일반/특수 대시 모두 대응
        when '==>'                 then ' ⟹ '
        when '>>>'                 then ' ➤ ' # C++ >> 와 겹치지 않게 >>> 사용 권장
        else match
        end
      end
    end
  end

  # 본문 변환
  doc.content = replacer.call(doc.content)

  # 제목 변환 (HTML id 생성 등에 영향을 주지 않도록 데이터 필드 직접 수정)
  if doc.data['title']
    doc.data['title'] = replacer.call(doc.data['title'])
  end
end
