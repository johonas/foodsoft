class AddEndsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :end_date, :date, :null => true
  end
end
