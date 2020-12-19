class AddBookReferenceToPost < ActiveRecord::Migration[6.0]
  def change
    add_reference :posts, :book, index: true
  end
end
