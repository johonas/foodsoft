class RemoveResultFromGroupOrderArticles < ActiveRecord::Migration
  def change
    execute('DELETE FROM group_order_articles WHERE result IS NULL')
    execute('UPDATE group_order_articles SET quantity = result')
    remove_column :group_order_articles, :result
    remove_column :group_order_articles, :result_computed
  end
end
