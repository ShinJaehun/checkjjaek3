class Group < ApplicationRecord
  resourcify
  # rolify의 영향을 받는 resource

  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups

  validates :name, presence: true, uniqueness: true

  has_many :post_recipient_groups, foreign_key: :recipient_group_id, dependent: :destroy
  #has_many :post_recipient_groups, foreign_key: :recipient_group_id
  #has_many :posts, through: :post_recipient_groups

  has_one_attached :cover_image
end
