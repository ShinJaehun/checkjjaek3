class CreateBooks < ActiveRecord::Migration[6.0]
  def change
    create_table :books do |t|
      t.string :title
      t.string :contents
      t.string :isbn
      t.string :publisher
      t.string :thumbnail

      t.timestamps
    end
  end
end
