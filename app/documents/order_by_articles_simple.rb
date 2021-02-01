# encoding: utf-8
class OrderByArticlesSimple < OrderPdf

  def filename
    I18n.t('documents.order_by_articles.filename', :name => order.name, :date => order.ends.to_date) + '.pdf'
  end

  def title
    I18n.t('documents.order_by_articles.title', :name => order.name,
      :date => order.ends.strftime(I18n.t('date.formats.default')))
  end

  def body
    # TODO: Translate
    rows = [[
              Article.human_attribute_name(:name),
              'Einheiten bestellt',
              'Aus Lager',
              'Gebinde zu bestellen',
              'Gebindegrösse',
            ]]

    dimrows = []

    each_order_article do |order_article|

      rows << [
        order_article.article.name,
        order_article.quantity,
        order_article.quantity_from_stock,
        order_article.units_to_order,
        order_article.article.unit_quantity
      ]

      # dimrows << rows.length if order_article.units_to_order == 0
    end

    nice_table '', rows, dimrows do |table|
      table.column(0).width = bounds.width / 2
      table.columns(1..-1).align = :right
      # table.column(0).font_style = :bold
    end
  end
end
