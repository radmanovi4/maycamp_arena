class ChangeProviderType < ActiveRecord::Migration
  def up
    change_column :users, :provider, :integer, default: 0
  end

  def down
    change_column :users, :provider, :string
  end
end
