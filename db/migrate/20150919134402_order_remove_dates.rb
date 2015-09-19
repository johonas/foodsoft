class OrderRemoveDates < ActiveRecord::Migration
  def change
    remove_column :orders, :starts
    remove_column :orders, :ends
  end
end
