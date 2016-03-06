class GroupsChangeRoleVerteilen < ActiveRecord::Migration
  def up
    change_column :groups, :role_verteilen, :boolean, :default => false, :null => false
  end

  def down
    raise 'not supported'
  end
end
