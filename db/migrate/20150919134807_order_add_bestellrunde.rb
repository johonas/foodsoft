class OrderAddBestellrunde < ActiveRecord::Migration
  def change
    add_column :orders, :bestellrunde_id, :integer, :null => false
  end
end
