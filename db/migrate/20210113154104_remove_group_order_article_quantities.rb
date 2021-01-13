class RemoveGroupOrderArticleQuantities < ActiveRecord::Migration
  def up
    drop_table :group_order_article_quantities
  end

  def down
    fail 'Can not be reverted'
  end
end
