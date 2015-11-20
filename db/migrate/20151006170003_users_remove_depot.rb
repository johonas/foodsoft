class UsersRemoveDepot < ActiveRecord::Migration
  def change
    remove_column :users, :depot_id

  end
end
