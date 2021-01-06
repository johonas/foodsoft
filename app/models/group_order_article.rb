# A GroupOrderArticle stores the sum of how many items of an OrderArticle are ordered as part of a GroupOrder.
# The chronologically order of the Ordergroup - activity are stored in GroupOrderArticleQuantity
#
class GroupOrderArticle < ActiveRecord::Base

  belongs_to :group_order
  belongs_to :order_article
  has_many   :group_order_article_quantities, :dependent => :destroy

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
  def update_quantities(quantity)
    logger.debug("Current quantity = #{self.quantity}")

    # When quantity is zero, we don't serve any purpose
    if quantity == 0
      logger.debug("Self-destructing since requested quantity is zero")
      destroy!
      return
    end

    # Get quantities ordered with the newest item first.
    quantities = group_order_article_quantities.order('created_on DESC').to_a
    logger.debug("GroupOrderArticleQuantity items found: #{quantities.size}")

    if (quantities.size == 0)
      # There is no GroupOrderArticleQuantity item yet, just insert with desired quantities...
      logger.debug("No quantities entry at all, inserting a new one with the desired quantities")
      quantities.push(GroupOrderArticleQuantity.new(:group_order_article => self, :quantity => quantity))
      self.quantity = quantity
    else
      # Decrease quantity if necessary by going through the existing items and decreasing their values...
      i = 0
      while (i < quantities.size && quantity < self.quantity)
        logger.debug("Need to decrease quantities for GroupOrderArticleQuantity[#{quantities[i].id}]")
        if (quantity < self.quantity && quantities[i].quantity > 0)
          delta = self.quantity - quantity
          delta = (delta > quantities[i].quantity ? quantities[i].quantity : delta)
          logger.debug("Decreasing quantity by #{delta}")
          quantities[i].quantity -= delta
          self.quantity -= delta
        end
        i += 1
      end
      # If there is at least one increased value: insert a new GroupOrderArticleQuantity object
      if quantity > self.quantity
        logger.debug("Inserting a new GroupOrderArticleQuantity")
        quantities.insert(0, GroupOrderArticleQuantity.new(
            :group_order_article => self,
            :quantity => (quantity > self.quantity ? quantity - self.quantity : 0)
        ))
        # Recalc totals:
        self.quantity += quantities[0].quantity
      end
    end

    # Check if something went terribly wrong and quantites have not been adjusted as desired.
    if self.quantity != quantity
      raise 'Invalid state: unable to update GroupOrderArticle/-Quantities to desired quantities!'
    end

    # Remove zero-only items.
    quantities = quantities.reject { | q | q.quantity == 0 }

    # Save
    transaction do
      quantities.each { | i | i.save! }
      self.group_order_article_quantities = quantities
      save!
    end
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
