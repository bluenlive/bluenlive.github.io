# # _plugins/custom_emphasis.rb

# # 1. 마크다운 렌더링 전: 언더스코어를 안전한 임시 표커로 치환
# Jekyll::Hooks.register :documents, :pre_render do |doc|
#   next unless doc.extname == ".md"

#   # 보호 구역 격리 (코드 블록 등)
#   protected_items = []
#   protection_regex = /(^```.*?^```|^~~~.*?^~~~|`.*?`||\$\$.*?\$\$|\{%.*?%\}|\{\{.*?\}\})/m
#   doc.content = doc.content.gsub(protection_regex) { |m| placeholder = "@@SAFE_#{protected_items.length}@@"; protected_items << m; placeholder }

#   # 정규표현식 개선: (?<!\w)와 (?!\w)를 사용하여 단어 중간의 _는 보호하고, 
#   # 백슬래시(\)나 대괄호([)가 뒤에 와도 정확히 인식하도록 수정
#   double_regex = /(?<!\w)__(?=\S)(.+?)(?<=\S)__(?!\w)/
#   single_regex = /(?<!\w)_(?=\S)(.+?)(?<=\S)_(?!\w)/

#   # 임시 이름표로 변환 (Jekyll의 렌더링 방해 금지)
#   doc.content.gsub!(double_regex, '⦗COMMENT_START⦘\1⦗COMMENT_END⦘')
#   doc.content.gsub!(single_regex, '⦗DESC_START⦘\1⦗DESC_END⦘')

#   # 보호 구역 복구
#   protected_items.each_with_index { |orig, i| doc.content.gsub!("@@SAFE_#{i}@@", orig) }
# end

# # 2. 마크다운 렌더링 후: 임시 표커를 최종 HTML 태그로 변환
# Jekyll::Hooks.register :documents, :post_render do |doc|
#   next unless doc.extname == ".md"

#   # ⦗ ⦘ 기호는 일반적인 본문에 거의 쓰이지 않는 특수 기호입니다.
#   doc.output.gsub!('⦗COMMENT_START⦘', '<span class="comment">')
#   doc.output.gsub!('⦗COMMENT_END⦘', '</span>')
#   doc.output.gsub!('⦗DESC_START⦘', '<span class="desc">')
#   doc.output.gsub!('⦗DESC_END⦘', '</span>')
# end
