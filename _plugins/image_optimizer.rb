require 'fastimage'

Jekyll::Hooks.register :documents, :post_render do |doc|
  # 마크다운 파일에서 변환된 HTML만 대상으로 합니다.
  next unless doc.extname == ".md"

  image_count = 0

  # HTML 내의 모든 <img> 태그를 찾아 속성을 분석하고 수정합니다.
  doc.output.gsub!(/<img\s+([^>]+)>/) do |match|
    attributes = $1.dup
    image_count += 1
    
    # 1. 이미지 경로 추출 및 크기(Width/Height) 자동 계산
    if attributes =~ /src=["']([^"']+)["']/
      src = $1
      
      # [안정성 강화] 경로 시작의 '/'를 제거하여 Jekyll 소스 경로와 올바르게 결합합니다.
      relative_path = src.sub(%r{^/}, '')
      file_path = File.join(doc.site.source, relative_path)
      
      # 파일이 실제로 존재하고, 아직 width 속성이 없을 때만 처리합니다.
      if File.exist?(file_path) && !attributes.include?('width=')
        begin
          # FastImage는 이미지 헤더만 읽으므로 매우 빠릅니다.
          size = FastImage.size(file_path)
          if size
            attributes << " width=\"#{size[0]}\" height=\"#{size[1]}\""
          end
        rescue StandardError => e
          Jekyll.logger.warn "Image Optimizer:", "Could not get size for #{file_path}: #{e.message}"
        end
      end
    end

    # 2. 로딩 전략 최적화 (LCP 향상 및 이미지 누락 방지)
    # 기존에 명시된 loading 속성이 있다면 제거하고 새로 설정합니다.
    attributes.gsub!(/\s*loading=["'][^"']+["']/, '')
    
    if image_count <= 2
      # 상단 2장은 즉시 로딩 (eager)
      attributes << ' loading="eager"'
    else
      # 나머지는 지연 로딩 (lazy)
      attributes << ' loading="lazy"'
    end

    # 3. 중앙 정렬 자동화 (Minimal Mistakes 테마 스타일 호환)
    # 이미 정렬 클래스가 있는지 확인하고, 없으면 align-center를 추가합니다.
    unless attributes =~ /class=["'][^"']*(align-left|align-right|align-center)[^"']*["']/
      if attributes =~ /class=["']([^"']+)["']/
        # 기존 클래스가 있다면 뒤에 추가
        attributes.sub!(/class=["']([^"']+)["']/, 'class="\1 align-center"')
      else
        # 클래스 속성 자체가 없다면 새로 생성
        attributes << ' class="align-center"'
      end
    end

    # 최종 수정된 속성으로 <img> 태그 재구성
    "<img #{attributes}>"
  end
end