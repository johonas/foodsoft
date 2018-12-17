class OrdersAddStartsAndEnds < ActiveRecord::Migration
  def up
    add_column :orders, :starts, :datetime, after: :note
    add_column :orders, :ends, :datetime, after: :starts

    remove_column :orders, :end_date

    execute <<-SQL
    UPDATE orders o 
    JOIN bestellrunden b ON b.id = o.bestellrunde_id
    SET o.starts = STR_TO_DATE(CONCAT(b.starts, ' 12:00:00'), '%Y-%m-%d %H:%i:%s'),
        o.ends = STR_TO_DATE(CONCAT(b.ends, ' 12:00:00'), '%Y-%m-%d %H:%i:%s');
    SQL
  end

  def down
    fail 'Not supported'
  end
end
