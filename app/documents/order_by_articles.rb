# encoding: utf-8
class OrderByArticles < OrderPdf

  def filename
    I18n.t('documents.order_by_articles.filename', :name => order.name, :date => order.ends.to_date) + '.pdf'
  end

  def title
    I18n.t('documents.order_by_articles.title', :name => order.name,
      :date => order.ends.strftime(I18n.t('date.formats.default')))
  end

  def body
    each_order_article do |order_article|
      dimrows = []
      rows = [[
        GroupOrder.human_attribute_name(:ordergroup),
        GroupOrderArticle.human_attribute_name(:ordered),
        GroupOrderArticle.human_attribute_name(:total_price)
      ]]

      each_group_order_article_for_order_article(order_article) do |goa|
        dimrows << rows.length if goa.quantity == 0
        rows << [goa.group_order.ordergroup_name,
                 goa.quantity,
                 number_to_currency(goa.total_price)]
      end
      next unless rows.length > 1

      name = "#{order_article.article.name} (#{order_article.article.unit} | #{order_article.price.unit_quantity} | #{number_to_currency(order_article.price.fc_price)})"
      name += " #{order_article.article.supplier.name}" if @options[:show_supplier]
      nice_table name, rows, dimrows do |table|
        table.column(0).width = bounds.width / 2
        table.columns(1..-1).align = :right
        table.column(1).font_style = :bold
      end
    end
  end
end
