class CreateDepots < ActiveRecord::Migration
  def change
    create_table :depots do |t|

      t.column :name, :string, :null => false

      t.timestamps null: false
    end
  end
end
