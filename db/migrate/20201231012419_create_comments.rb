class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.references :commentable, polymorphic: true, null: false
      t.text :content
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
