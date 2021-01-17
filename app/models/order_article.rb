# An OrderArticle represents a single Article that is part of an Order.
class OrderArticle < ActiveRecord::Base
  include FindEachWithOrder

  attr_reader :update_global_price

  belongs_to :order
  belongs_to :article
  belongs_to :article_price
  has_many :group_order_articles, :dependent => :destroy

  validates_presence_of :order_id, :article_id
  validate :article_and_price_exist
  validates_uniqueness_of :article_id, scope: :order_id

  _ordered_sql = "order_articles.units_to_order > 0 OR order_articles.units_billed > 0 OR order_articles.units_received > 0"
  scope :ordered, -> { where(_ordered_sql) }
  scope :ordered_or_member, -> { includes(:group_order_articles).where("#{_ordered_sql} OR order_articles.quantity > 0") }

  before_create :init_from_balancing
  after_destroy :update_ordergroup_prices

  # This method returns either the ArticlePrice or the Article
  # The first will be set, when the the order is finished
  def price
    article_price || article
  end

  # latest information on available units
  def units
    return units_received unless units_received.nil?
    return units_billed unless units_billed.nil?
    return calc_units if order.open?
    units_to_order
  end

  # Count quantities of belonging group_orders.
  # In balancing this can differ from ordered (by supplier) quantity for this article.
  def group_orders_sum
    quantity = group_order_articles.collect(&:quantity).sum
    {:quantity => quantity, :price => quantity * price.fc_price}
  end

  # Update quantity/units_to_order from group_order_articles
  def update_results!
    if order.open?
      self.quantity = group_order_articles.collect(&:quantity).sum
      self.units_to_order = calc_units_to_order
      save!
    elsif order.finished?
      update_attribute(:units_to_order, calc_units_to_order)
    end
  end

  def calc_units
    (self.quantity / price.unit_quantity.to_f).ceil
  end

  def calc_units_to_order
    if self.quantity <= quantity_from_stock
      units_to_order = 0
    else
      units_to_order = ((self.quantity - quantity_from_stock) / price.unit_quantity.to_f).ceil
    end

    units_to_order
  end

  def quantity_from_stock
    stock = order.open? ? article.stock_quantity : stock_quantity
    stock ||= 0
    stock >= self.quantity ? self.quantity : stock
  end

  def order_finished!
    fail 'Order not finished' unless order.finished?

    update_attribute(:article_price, article.article_prices.first)

    if quantity > 0 && !order.stockit?
      fail 'Article already has stock_quantity set' unless stock_quantity.nil?

      if (ordered_from_stock = article.order_from_stock!(quantity, self))
        update_attribute(:stock_quantity, ordered_from_stock)
      end
    end

    update_results!
  end

  # Calculate price for ordered quantity.
  def total_price
    units * price.unit_quantity * price.price
  end

  # Calculate gross price for ordered qunatity.
  def total_gross_price
    units * price.unit_quantity * price.gross_price
  end

  def ordered_quantities_different_from_group_orders?(ordered_mark="!", billed_mark="?", received_mark="?")
    if not units_received.nil?
      ((units_received * price.unit_quantity) == group_orders_sum[:quantity]) ? false : received_mark
    elsif not units_billed.nil?
      ((units_billed * price.unit_quantity) == group_orders_sum[:quantity]) ? false : billed_mark
    elsif not units_to_order.nil?
      ((units_to_order * price.unit_quantity) == group_orders_sum[:quantity]) ? false : ordered_mark
    else
      nil # can happen in integration tests
    end
  end

  def restock
    items_ordered  = units_to_order * price.unit_quantity
    items_received = units_received * price.unit_quantity

    ArticleStockChange.where(order_article: self).destroy_all

    # if there's anything left, move to stock if wanted
    if items_ordered != items_received
      ArticleStockChange.create!(article: self.article, order_article: self,
                                 quantity: items_received - items_ordered,
                                 change_type: :restock)
    end
  end

  # Updates order_article and belongings during balancing process
  def update_article_and_price!(order_article_attributes, article_attributes, price_attributes = nil)
    OrderArticle.transaction do
      # Updates self
      self.update_attributes!(order_article_attributes)

      # Updates article
      article.update_attributes!(article_attributes)

      # Updates article_price belonging to current order article
      if price_attributes.present?
        article_price.attributes = price_attributes
        if article_price.changed?
          # Updates also price attributes of article if update_global_price is selected
          if update_global_price
            article.update_attributes!(price_attributes)
            self.article_price = article.article_prices.first and save # Assign new created article price to order article
          else
            # Creates a new article_price if neccessary
            # Set created_at timestamp to order ends, to make sure the current article price isn't changed
            create_article_price!(price_attributes.merge(created_at: order.ends)) and save
            # TODO: The price_attributes do not include an article_id so that
            #   the entry in the database will not "know" which article is
            #   referenced. Let us check the effect of that and change it or
            #   comment on the meaning.
            #   Possibly this is the real reason why the global price is not
            #   affected instead of the `created_at: order.ends` injection.
          end

          # Updates ordergroup values
          update_ordergroup_prices
        end
      end
    end
  end

  def update_global_price=(value)
    @update_global_price = (value == true || value == '1') ?  true : false
  end

  private

  def article_and_price_exist
    errors.add(:article, I18n.t('model.order_article.error_price')) if !(article = Article.find(article_id)) || article.fc_price.nil?
  rescue
    errors.add(:article, I18n.t('model.order_article.error_price'))
  end

  # Associate with current article price if created in a finished order
  def init_from_balancing
    if order.present? && order.finished?
      self.article_price = article.article_prices.first
    end
  end

  def update_ordergroup_prices
    # updates prices of ALL ordergroups - these are actually too many
    # in case of performance issues, update only ordergroups, which ordered this article
    # CAUTION: in after_destroy callback related records (e.g. group_order_articles) are already non-existent
    order.group_orders.each(&:update_price!)
  end
end
