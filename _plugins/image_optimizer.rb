require 'fastimage'

# 시점을 :post_convert로 변경하여 본문 내용만 타겟팅합니다.
Jekyll::Hooks.register :documents, :post_convert do |doc|
  # 마크다운 파일에서 변환된 내용만 대상으로 합니다.
  next unless doc.extname == ".md"

  image_count = 0

  # doc.output 대신 doc.content를 직접 수정합니다.
  # 이 시점의 doc.content는 레이아웃이 적용되기 전의 순수 본문 HTML입니다.
  doc.content.gsub!(/<img\s+([^>]+)>/) do |match|
    attributes = $1.dup
    image_count += 1
    
    # 1. 이미지 경로 추출 및 크기(Width/Height) 자동 계산
    if attributes =~ /src=["']([^"']+)["']/
      src = $1
      relative_path = src.sub(%r{^/}, '')
      file_path = File.join(doc.site.source, relative_path)
      
      if File.exist?(file_path) && !attributes.include?('width=')
        begin
          size = FastImage.size(file_path)
          if size
            attributes << " width=\"#{size[0]}\" height=\"#{size[1]}\""
          end
        rescue StandardError => e
          Jekyll.logger.warn "Image Optimizer:", "Could not get size for #{file_path}: #{e.message}"
        end
      end
    end

    # 2. 로딩 전략 최적화
    attributes.gsub!(/\s*loading=["'][^"']+["']/, '')
    if image_count <= 2
      attributes << ' loading="eager"'
    else
      attributes << ' loading="lazy"'
    end

    # 3. 중앙 정렬 자동화 (본문 이미지이므로 예외 처리 없이 적용)
    unless attributes =~ /class=["'][^"']*(align-left|align-right|align-center)[^"']*["']/
      if attributes =~ /class=["']([^"']+)["']/
        attributes.sub!(/class=["']([^"']+)["']/, 'class="\1 align-center"')
      else
        attributes << ' class="align-center"'
      end
    end

    "<img #{attributes}>"
  end
end