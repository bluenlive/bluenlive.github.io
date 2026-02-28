# _plugins/custom_markers.rb
Jekyll::Hooks.register :documents, :post_render do |doc|
  next unless doc.extname == ".md"

  # 보호해야 할 컨테이너 태그 목록
  # 이 태그들 내부에 있는 텍스트는 절대 건드리지 않습니다.
  protected_tags = %w[pre code script style math]
  inside_protected_tag = false

  # HTML을 태그와 텍스트로 분리하여 처리
  doc.output = doc.output.split(/(<[^>]+>)/).map do |part|
    if part =~ /^<(\/)?([a-z0-9]+)/i
      tag_name = $2.downcase
      is_closing = !$1.nil?

      if protected_tags.include?(tag_name)
        inside_protected_tag = !is_closing
      end
      part # 태그 자체는 그대로 반환
    elsif !inside_protected_tag
      # 보호 구역이 아닐 때만 정확히 4개(comment), 3개(desc) 순으로 치환
      res = part.dup
      
      # 1. ::::내용:::: -> <span class="comment">내용</span>
      res.gsub!(/(?<!:):{4}(?!:)(.+?)(?<!:):{4}(?!:)/, '<span class="comment">\1</span>')
      
      # 2. :::내용::: -> <span class="desc">내용</span>
      res.gsub!(/(?<!:):{3}(?!:)(.+?)(?<!:):{3}(?!:)/, '<span class="desc">\1</span>')
      
      res
    else
      part # 보호 구역 내부의 텍스트는 그대로 반환
    end
  end.join
end