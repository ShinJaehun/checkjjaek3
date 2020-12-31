class AddParentToComments < ActiveRecord::Migration[6.0]
  def change
    add_reference :comments, :parent, index: true
  end
end
