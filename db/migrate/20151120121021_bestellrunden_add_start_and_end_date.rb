class BestellrundenAddStartAndEndDate < ActiveRecord::Migration
  def change
    add_column :bestellrunden, :starts, :date, :null => false
    add_column :bestellrunden, :ends, :date, :null => false

    remove_column :bestellrunden, :season
    remove_column :bestellrunden, :year

  end
end
