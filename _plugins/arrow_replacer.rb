Jekyll::Hooks.register :posts, :pre_render do |post|
  # 1. 무시할 영역: 코드 블록(```, ~~~), 인라인 코드(`), HTML 주석()
  # 2. 변환할 영역: ==>, -->, >> 
  regex = /(^```.*?^```|^~~~.*?^~~~|`.*?`|)|(==>|-->|>>)/m

  post.content.gsub!(regex) do |match|
    if $1 # 무시 영역에 해당하면 그대로 반환
      match
    else # 화살표 기호에 해당할 때만 치환
      case $2
      when '-->' then ' ⟶ '
      when '==>' then ' ⟹ '
      when '>>'  then ' ➤ '
      else match
      end
    end
  end
end
