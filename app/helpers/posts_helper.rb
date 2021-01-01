module PostsHelper
  def render_with_hashtags(content)
    content.gsub(/[#＃][a-z|A-Z|가-힣|0-9|\w]+/){
      |word| 
        if word.include? "#"
          link_to word, "/posts/hashtag/#{word.downcase.delete("#")}"
        else
          word
        end
    }.html_safe
  end
end
