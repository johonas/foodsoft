class AddChangeTypeToArticleStockChanges < ActiveRecord::Migration
  def up
    add_column :article_stock_changes, :change_type, :string, after: :quantity, null: true
    execute("UPDATE article_stock_changes SET change_type = 'manual' WHERE created_by_id IS NOT NULL")
    execute("UPDATE article_stock_changes SET change_type = 'order' WHERE order_article_id IS NOT NULL")
    change_column :article_stock_changes, :change_type, :string, null: false
  end

  def down
    remove_column :article_stock_changes, :change_type
  end
end
