class CreatePostRecipientUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :post_recipient_users do |t|
      t.belongs_to :recipient_user, references: :users
      t.belongs_to :post, index: true

      t.timestamps
    end
  end
end
