class CreateArticleStockChanges < ActiveRecord::Migration
  def up
    create_table :article_stock_changes do |t|
      t.belongs_to :article, null: false
      t.belongs_to :created_by, references: :users, null: true
      t.belongs_to :order_article, null: true
      t.integer :quantity, null: false

      t.timestamps null: false
    end
  end

  def down
    drop_table :article_stock_changes
  end
end
