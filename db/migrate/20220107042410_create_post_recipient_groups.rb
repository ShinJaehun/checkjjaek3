class CreatePostRecipientGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :post_recipient_groups do |t|
      t.belongs_to :recipient_group, references: :groups
      t.belongs_to :post, index: true

      t.timestamps
    end
  end
end
