class AddDepotIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :depot_id, :integer, :null => true
  end
end
