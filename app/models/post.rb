class Post < ApplicationRecord
  validates :content, presence: { message: '내용을 입력하세요' }, length: { maximum: 200 }
  validates :user_id, presence: true

  # belongs_to :user, :counter_cache => :posts_count
  belongs_to :user

  # belongs_to :book
  belongs_to :postable, polymorphic: true

  has_many :likes, dependent: :destroy
  has_many :like_users, through: :likes, source: :user

  def toggle_like(user)
    if self.like_users.include?(user)
      self.like_users.delete(user)
    else
      self.like_users.push(user)
    end
  end

  has_many :comments, as: :commentable, dependent: :destroy

  has_and_belongs_to_many :tags

  after_create do
    post = Post.find_by(id: self.id)
    hashtags = self.content.scan(/[#＃][a-z|A-Z|가-힣|0-9|\w]+/)
    hashtags.uniq.map do |hashtag|
      tag = Tag.find_or_create_by(name: hashtag.downcase.delete('#'))
      post.tags << tag
    end
  end

  before_update do
    post = Post.find_by(id: self.id)
    post.tags.clear
    hashtags = self.content.scan(/[#＃][a-z|A-Z|가-힣|0-9|\w]+/)
    hashtags.uniq.map do |hashtag|
      tag = Tag.find_or_create_by(name: hashtag.downcase.delete('#'))
      post.tags << tag
    end
  end

end
