# A GroupOrderArticle stores the sum of how many items of an OrderArticle are ordered as part of a GroupOrder.
class GroupOrderArticle < ActiveRecord::Base

  belongs_to :group_order
  belongs_to :order_article

  validates_presence_of :group_order, :order_article
  validates_uniqueness_of :order_article_id, :scope => :group_order_id    # just once an article per group order

  scope :ordered, -> { includes(:group_order => :ordergroup).order('groups.name') }

  # Setter used in group_order_article#new
  # We have to create an group_order, if the ordergroup wasn't involved in the order yet
  def ordergroup_id=(id)
    self.group_order = GroupOrder.where(order_id: order_article.order_id, ordergroup_id: id).first_or_initialize
  end

  def ordergroup_id
    group_order.try!(:ordergroup_id)
  end

  # Updates the quantity for this GroupOrderArticle by updating both GroupOrderArticle properties
  # and the associated GroupOrderArticleQuantities chronologically.
  #
  # See description of the ordering algorithm in the general application documentation for details.
  def update_quantity!(quantity)
    logger.debug("Current quantity = #{self.quantity}")

    # When quantity is zero, we don't serve any purpose
    if quantity == 0
      logger.debug("Self-destructing since requested quantity is zero")
      destroy!
      return
    end

    self.quantity = quantity
    save!
  end

  # Returns order result,
  # either calcualted on the fly or fetched from result attribute
  # Result is set when finishing the order.
  def result(type = :total)
    fail 'Depricated: Use quantity instead'
    # self[:result] || calculate_result[type]
  end

  # Returns total price for this individual article
  # Until the order is finished this will be the maximum price or
  # the minimum price depending on configuration. When the order is finished it
  # will be the value depending of the article results.
  def total_price(order_article = self.order_article)
    order_article.article.fc_price * quantity
  end
end
