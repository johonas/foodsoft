class RemoveBoxfillFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :boxfill, :datetime
  end
end
