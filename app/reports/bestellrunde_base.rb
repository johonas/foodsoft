module Reports
  class BestellrundeBase < Reporting::BaseExcelReport

    def initialize(supplier = nil)
      @supplier = supplier
      super()
    end

    def filename
      @filename
    end

    protected

    def header
      # '&L&G&C&12&BExport'
    end

    def footer
      '&C&9&R&9&P / &N'
    end

    def data
      raw_data = {}
      data = {}

      @bestellrunde.group_orders.preload(ordergroup: :depot, group_order_articles: { order_article: :article }).each do |group_order|

        ordergroup = group_order.ordergroup
        next unless ordergroup
        depot = ordergroup.depot
        group_order_articles = group_order.group_order_articles

        if @supplier
          group_order_articles = group_order.group_order_articles
                                            .select { |goa| goa.order_article.article.supplier_id == @supplier.id }
        end

        next if group_order_articles.none?

        raw_data[depot] ||= {}

        group_order_articles.each do |group_order_article|
          order_article = group_order_article.order_article

          raw_data[depot][order_article] ||= {}
          raw_data[depot][order_article][ordergroup] = group_order_article.quantity
        end
      end

      raw_data.each do |depot, order_articles|
        data[depot] = {}
        data[depot][:ordergroups] = SortedSet.new
        data[depot][:articles]    = []

        order_articles.each do |order_article, ordergroups|
          article = order_article.article
          article_row = {}
          article_row[:product] = article.name
          article_row[:stock] = order_article.stock_quantity && order_article.stock_quantity > 0 ? 'x' : ''
          article_row[:supplier] = article.supplier.name if @supplier.nil?
          article_row[:unit] = article.unit

          ordergroups.each do |ordergroup, amount|
            article_row[ordergroup.name] = amount
            data[depot][:ordergroups] << ordergroup.name
          end

          data[depot][:articles] << article_row
        end

        data[depot][:articles] = data[depot][:articles].sort_by{ |r| r[:product] }
      end

      return data
    end

  end
end
