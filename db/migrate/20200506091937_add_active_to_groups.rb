class AddActiveToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :active, :boolean, default: true, null: false, after: :type
  end
end
