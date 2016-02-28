class RenameProviderIdColumn < ActiveRecord::Migration
  def change
    rename_column :users, :uid, :provider_id
  end
end
