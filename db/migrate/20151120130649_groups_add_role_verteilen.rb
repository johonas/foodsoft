class GroupsAddRoleVerteilen < ActiveRecord::Migration
  def change
    add_column :groups, :role_verteilen, :boolean, :Default => false, :null => false
  end
end
