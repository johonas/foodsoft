class AddPeopleCountToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :people_count, :integer, null: false, default: 1
  end
end
