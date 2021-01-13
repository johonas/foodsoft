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
            article = group_order_article.order_article.article

            if !@supplier.nil? && article.supplier != @supplier
              next
            end

            article.stock = order.stockit?

            raw_data[depot][article] ||= {}
            raw_data[depot][article][group_order.ordergroup] = group_order_article.quantity
          end
        end
      end

      raw_data.each do |depot, articles|
        data[depot] = {}
        data[depot][:ordergroups] = SortedSet.new
        data[depot][:articles]    = []

        articles.each do |article, ordergroups|
          article_row = {}
          article_row[:product] = article.name
          article_row[:stock] = article.stock ? 'x' : ''
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
