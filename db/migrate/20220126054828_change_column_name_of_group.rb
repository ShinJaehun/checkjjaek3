class ChangeColumnNameOfGroup < ActiveRecord::Migration[6.0]
  def change
    rename_column :groups, :state, :group_state
  end
end
