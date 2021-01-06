class RemoveTolerance < ActiveRecord::Migration
  def change
    remove_column :group_order_article_quantities, :tolerance, :integer, default: 0, null: false
    remove_column :group_order_articles, :tolerance, :integer, default: 0, null: false
    remove_column :order_articles, :tolerance, :integer, default: 0, null: false
  end
end
