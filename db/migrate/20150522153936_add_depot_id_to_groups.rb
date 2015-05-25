class AddDepotIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :depot_id, :integer, :null => false

  end
end
