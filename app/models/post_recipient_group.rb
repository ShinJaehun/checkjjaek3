class PostRecipientGroup < ApplicationRecord
  belongs_to :post
  belongs_to :recipient_group, class_name: :Group
end
