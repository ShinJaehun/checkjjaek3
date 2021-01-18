class Message < ApplicationRecord
#  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
#  belongs_to :receiver, class_name: "User", foreign_key: "receiver_id"

  #validates_uniqueness_of :sender_id, scope: :receiver_id

  has_many :posts, as: :postable
  accepts_nested_attributes_for :posts
end
