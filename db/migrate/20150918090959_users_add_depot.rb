class UsersAddDepot < ActiveRecord::Migration
  def change
    add_column :users, :depot_id, :integer, :null => true
  end
end
