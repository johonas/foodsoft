module Reports
  class BestellrundeBase < Reporting::BaseExcelReport

    def initialize(supplier=nil)
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

      @bestellrunde.orders.each do |order|

        order.group_orders.each do |group_order|

          # TODO: Why can there be an GroupOrder without ordergroup?
          next unless group_order.ordergroup

          depot = group_order.ordergroup.depot

          raw_data[depot] ||= {}
          group_order.group_order_articles.each do |group_order_article|
            order_article = group_order_article.order_article

            if !@supplier.nil? && order_article.article.supplier != @supplier
              next
            end

            raw_data[depot][order_article] ||= {}
            raw_data[depot][order_article][group_order.ordergroup] = group_order_article.quantity
          end
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
          article_row[:stock] = order_article.stock_quantity > 0 ? 'x' : ''
          if @supplier.nil?
            article_row[:supplier] = article.supplier.name
          end
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
