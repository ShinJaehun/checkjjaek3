class Group < ApplicationRecord
  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups

  validates :name, presence: true, uniqueness: true

  has_many :post_recipient_groups, foreign_key: :recipient_group_id, dependent: :destroy
  #has_many :post_recipient_groups, foreign_key: :recipient_group_id
  #has_many :posts, through: :post_recipient_groups
end
