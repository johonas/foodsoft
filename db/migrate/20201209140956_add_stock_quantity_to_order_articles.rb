class AddStockQuantityToOrderArticles < ActiveRecord::Migration
  def change
    add_column :order_articles, :stock_quantity, :integer, after: :quantity
  end
end
