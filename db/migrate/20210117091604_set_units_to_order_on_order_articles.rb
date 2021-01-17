class SetUnitsToOrderOnOrderArticles < ActiveRecord::Migration
  def change
    execute(
      <<-SQL
        UPDATE order_articles oa
        JOIN article_prices ap ON ap.id = oa.article_price_id
        JOIN orders o ON o.id = oa.order_id
        SET oa.units_to_order = CEIL(oa.quantity / COALESCE(ap.unit_quantity, 1))

        WHERE o.state != 'open';
      SQL
    )
  end
end
