# _plugins/image_optimizer.rb
Jekyll::Hooks.register :documents, :post_render do |doc|
  next unless doc.extname == ".md"

  image_count = 0
  doc.output.gsub!(/<img\s+([^>]+)>/) do |match|
    attributes = $1.dup
    image_count += 1
    
    # 1. 첫 두 장은 즉시 로드(eager), 그 이후부터는 레이지 로드(lazy)
    if image_count <= 2
      attributes.sub!(/loading=["'][^"']+["']/, '') # 기존 lazy 속성 제거
      attributes << ' loading="eager"'
    elsif !attributes.include?('loading=')
      attributes << ' loading="lazy"'
    end

    # 2. 중앙 정렬 자동화 (기존 로직 유지)
    unless attributes =~ /class=["'][^"']*(align-left|align-right|align-center)[^"']/
      if attributes =~ /class=["']([^"']+)["']/
        attributes.sub!(/class=["']([^"']+)["']/, 'class="\1 align-center"')
      else
        attributes << ' class="align-center"'
      end
    end

    "<img #{attributes}>"
  end
end
