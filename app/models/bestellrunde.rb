class Bestellrunde < ActiveRecord::Base
  has_many :orders

  def season_label
    return Bestellrunde.bestellrunden[self.season.to_sym][:label]
  end

  def label
    "#{self.starts}"
  end

  def self.selectable(order=nil)
    Bestellrunde.all.select do |bestelrunde|
      bestelrunde.ends >= Date.today || (order && order.bestellrunde == bestelrunde)
    end.map{ |b| [b.label, b.id]}
  end

  def aricles_by_group_order(ordergroup)

    articles = {}

    orders.each do |order|
      group_order = order.group_orders.where(:ordergroup => ordergroup).first
      next unless group_order

      articles[order] ||= {}

      group_order.order_articles_by_suppliers.each do |supplier, order_articles|
        articles[order][supplier] ||= []
        order_articles.each do |order_article|
          articles[order][supplier] << order_article
        end
      end

    end

    return articles

  end

end