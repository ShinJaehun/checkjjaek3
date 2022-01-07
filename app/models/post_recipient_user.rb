class PostRecipientUser < ApplicationRecord
  belongs_to :post
  belongs_to :recipient_user, class_name: :User
end
