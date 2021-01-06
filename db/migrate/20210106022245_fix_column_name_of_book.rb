class FixColumnNameOfBook < ActiveRecord::Migration[6.0]
  def change
    rename_column :books, :date_time, :datetime
  end
end
