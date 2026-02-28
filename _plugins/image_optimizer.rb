# _plugins/image_optimizer.rb
Jekyll::Hooks.register :documents, :post_render do |doc|
  next unless doc.extname == ".md"

  doc.output.gsub!(/<img\s+([^>]+)>/) do |match|
    attrs_str = $1.dup
    
    # 1. Lazy Loading: 중복 확인 후 안전하게 끝에 추가
    unless attrs_str.include?('loading=')
      attrs_str << ' loading="lazy"'
    end

    # 2. Align Center: 정렬 속성이 아예 없을 때만 추가
    # 정규표현식으로 align- 관련 클래스가 있는지 정밀 검사
    unless attrs_str =~ /class=["'][^"']*(align-left|align-right|align-center)[^"']*["']/
      if attrs_str =~ /class=["']([^"']+)["']/
        # 기존 클래스가 있으면 맨 뒤에 추가 (기존 클래스 유지)
        attrs_str.sub!(/class=(["'])([^"']+)\1/, "class=\\1\\2 align-center\\1")
      else
        # 클래스 속성 자체가 없으면 새로 생성
        attrs_str << ' class="align-center"'
      end
    end

    "<img #{attrs_str.strip}>"
  end
end
