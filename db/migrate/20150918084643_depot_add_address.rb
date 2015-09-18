class DepotAddAddress < ActiveRecord::Migration
  def change
    add_column :depots, :street, :string
    add_column :depots, :zip, :integer
    add_column :depots, :place, :string
    add_column :depots, :remark, :text


  end
end
