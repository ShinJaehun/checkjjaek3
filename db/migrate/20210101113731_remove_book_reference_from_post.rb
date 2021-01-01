class RemoveBookReferenceFromPost < ActiveRecord::Migration[6.0]
  def change
    remove_reference :posts, :book, index: true
  end
end
