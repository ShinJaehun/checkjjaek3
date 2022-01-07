class Group < ApplicationRecord
  has_many :user_groups
  has_many :users, through: :user_groups

  validates :name, presence: true, uniqueness: true

  has_many :post_recipient_groups, foreign_key: :recipient_group_id, dependent: :destroy
end
