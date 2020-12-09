class ArticleStockChange < ActiveRecord::Base
  belongs_to :article
  belongs_to :order_article
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by_id

  validate :user_or_order_article_set
  validate :quantity_not_below_zero
  validate :quantity_not_negative_for_order_articles

  validates :quantity, numericality: { only_integer: true, other_than: 0 }

  def order
    order_article&.order
  end

  def user_or_order_article_set
    unless created_by || order_article
      fail 'Either user or order_article must be set'
    end
  end

  def quantity_not_below_zero
    stock_quantity = article.stock_quantity || 0
    if quantity && stock_quantity + quantity < 0
      errors.add(:quantity, "Momentan nur #{stock_quantity} an Lager")
    end
  end

  def quantity_not_negative_for_order_articles
    if order_article && quantity > 0
      errors.add(:quantity, 'Quantity muss negativ sein bei Bestellungen')
    end
  end
end
