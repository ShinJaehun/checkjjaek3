module ApplicationHelper
#  def avatar_url(user)
#    # user email에서 gravatar_id를 추출하고 gravatar.com에서 해당하는 이미지를 불러옴 
#    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
#    "http://gravatar.com/avatar/#{gravatar_id}.png?d=retro&s=150"
#  end

  def user_avatar(user, size=40)
    if user.avatar.attached?
      user.avatar.variant(resize: "#{size}x#{size}!")
    else
      gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
      "http://gravatar.com/avatar/#{gravatar_id}.png?d=retro&s=#{size}"
    end
  end

  def extract_thumbnail110_url(url)
    # book image가 있으면 해당 url을, 없으면 no image avaliable 이미지를 리턴
    unless url.to_s.empty?
      #'http://t1.daumcdn.net/thumb/R110x0/?fname=' + URI.unescape(url.match(/http%.+/).to_s)
      # warning: URI.unescape is obsolete
      'http://t1.daumcdn.net/thumb/R110x0/?fname=' + CGI.unescape(url.match(/http%.+/).to_s)
    else
      'nia.jpg'
    end
  end
  
  def extract_thumbnail250_url(url)
    # book image가 있으면 해당 url을, 없으면 no image avaliable 이미지를 리턴
    unless url.to_s.empty?
      'http://t1.daumcdn.net/thumb/R260x0/?fname=' + CGI.unescape(url.match(/http%.+/).to_s)
    else
      'nia.jpg'
    end
  end
  
  # def book_thumbnail_search(url)
  #   # book image가 있으면 해당 url을, 없으면 no image avaliable 이미지를 리턴
  #   unless url.to_s.empty?
  #     "#{url}"
  #   else
  #     'nia.jpg'
  #   end
  # end
  
  def book_thumbnail150(url)
    # width가 150인 thumbnail 경로 리턴
    # 실제 사용하는 이미지의 width 200으로 좀 더 선명하게 보여줌
    # book image가 있으면 해당 url을, 없으면 no image avaliable 이미지를 리턴

    unless url.to_s.empty?
      'http://t1.daumcdn.net/thumb/R200x0/?fname=' + URI.encode(url)
    else
      'nia.jpg'
    end
  end
  
  def book_thumbnail250(url)
    # width가 150인 thumbnail 경로 리턴
    # 실제 사용하는 이미지의 width 200으로 좀 더 선명하게 보여줌
    # book image가 있으면 해당 url을, 없으면 no image avaliable 이미지를 리턴
  
    unless url.to_s.empty?
      'http://t1.daumcdn.net/thumb/R260x0/?fname=' + URI.encode(url)
    else
      'nia.jpg'
    end
  end
  
  # def book_from_post(post)
  #   # 이런 helper 쓰지 말고 그냥 post.postable을 사용하면 돼
  #   # post에서 book 정보를 가져옴
  #   unless post.nil?
  #     Book.find(post.postable_id)
  #   end
  # end
  
  def thumbnail input
    return self.images[input].variant(resize: '300x300!').processed
  end

  def group_cover_image(group)
    if group.cover_image.attached?
      group.cover_image.variant(resize: '300x300!')
    else
      'nia.jpg'
    end
  end

  def group_thumbnail(group)
    if group.cover_image.attached?
      group.cover_image.variant(resize: '100x100!')
    else
      'nia.jpg'
    end
  end
end
