class DepotAddOwener < ActiveRecord::Migration
  def change
    add_column :depots, :owner_id, :integer
  end
end
