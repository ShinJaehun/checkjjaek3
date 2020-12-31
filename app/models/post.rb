class Post < ApplicationRecord
  validates :content, presence: { message: '내용을 입력하세요' }, length: { maximum: 200 }
  validates :user_id, presence: true

  # belongs_to :user, :counter_cache => :posts_count
  belongs_to :user

  belongs_to :book

  has_many :likes, dependent: :destroy
  has_many :like_users, through: :likes, source: :user

  has_many :comments, as: :commentable, dependent: :destroy

  def toggle_like(user)
    if self.like_users.include?(user)
      self.like_users.delete(user)
    else
      self.like_users.push(user)
    end
  end


end
