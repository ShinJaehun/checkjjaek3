class AddOtherBookInformations < ActiveRecord::Migration[6.0]
  def change
    add_column :books, :authors, :string
    add_column :books, :translators, :string
    add_column :books, :date_time, :string
    add_column :books, :url, :text

    change_column :books, :contents, :text
    change_column :books, :thumbnail, :text
  end
end
