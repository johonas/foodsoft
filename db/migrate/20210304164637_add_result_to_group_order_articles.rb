class AddResultToGroupOrderArticles < ActiveRecord::Migration
  def change
    add_column :group_order_articles, :result, :integer
  end
end
