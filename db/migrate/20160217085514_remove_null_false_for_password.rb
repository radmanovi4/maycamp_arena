class RemoveNullFalseForPassword < ActiveRecord::Migration
  def up
    change_column :users, :password, :string, null: true
  end

  def down
    change_column :users, :password, :string, null: false
  end
end
