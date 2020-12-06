class AddColumnToPost < ActiveRecord::Migration[6.0]
  def change
    add_reference :posts, :user, index: true
  end
end
