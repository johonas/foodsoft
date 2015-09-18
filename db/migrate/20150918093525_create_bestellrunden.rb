class CreateBestellrunden < ActiveRecord::Migration
  def change
    create_table :bestellrunden do |t|

      t.column :season, :string, :null => false
      t.column :year, :integer, :null => false

      t.index [:season, :year], :unique => true

      t.timestamps null: false
    end
  end
end
