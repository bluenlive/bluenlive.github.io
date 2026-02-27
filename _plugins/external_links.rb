# _plugins/external_links.rb
Jekyll::Hooks.register :documents, :post_render do |doc|
  next unless doc.extname == ".md"

  site_url = doc.site.config['url'] || ""

  doc.output.gsub!(/<a\s+([^>]+)>/) do |match|
    attributes = $1.dup
    
    if attributes =~ /href=["']([^"']+)["']/
      href = $1
      
      # 1. 외부 링크 여부 확인 (상대 경로는 자연스럽게 제외됨)
      is_external = href.start_with?('http') && (site_url.empty? || !href.start_with?(site_url))

      if is_external
        # 2. target 처리: 없거나 이미 _blank인 경우에만 세팅
        if attributes !~ /target=/
          attributes << ' target="_blank"'
        end

        # 3. 보안 속성 처리: 결과적으로 target이 _blank인 경우에만 rel 추가/보정
        if attributes =~ /target=["']_blank["']/
          unless attributes =~ /rel=["']noopener noreferrer["']/
            if attributes =~ /rel=["']([^"']+)["']/
              # 기존 rel이 있다면 보안 속성만 추가
              existing_rel = $1
              unless existing_rel.include?('noopener')
                attributes.sub!(/rel=["']([^"']+)["']/, "rel=\"#{existing_rel} noopener noreferrer\"")
              end
            else
              # rel이 아예 없다면 새로 추가
              attributes << ' rel="noopener noreferrer"'
            end
          end
        end
        
        "<a #{attributes}>"
      else
        match
      end
    else
      match
    end
  end
end
