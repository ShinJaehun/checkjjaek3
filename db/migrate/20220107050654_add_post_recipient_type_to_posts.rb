class AddPostRecipientTypeToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :post_recipient_type, :string
  end
end
