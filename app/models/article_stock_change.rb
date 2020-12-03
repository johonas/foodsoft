class ArticleStockChange < ActiveRecord::Base
  belongs_to :article
  belongs_to :order
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by_id

  validate :user_or_order_set
  validate :quantity_not_below_zero

  validates :quantity, numericality: { only_integer: true, other_than: 0 }

  def user_or_order_set
    unless created_by || order
      fail 'Either user or order must be set'
    end
  end

  def quantity_not_below_zero
    stock_quantity = article.stock_quantity || 0
    if quantity && stock_quantity + quantity < 0
      errors.add(:quantity, "Momentan nur #{stock_quantity} an Lager")
    end
  end
end
