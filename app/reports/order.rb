module Reports
  class Order < Reporting::BaseExcelReport

    def initialize(order)
      @order = order
      @filename = "#{self.class.friendly_filename(order.supplier.name)}.xlsx"
      super()
    end

    def filename
      @filename
    end

    protected

    class OrderSheet < Reporting::TableXlsReport
      include ApplicationHelper

      def initialize(sheet, order)
        super(sheet)
        @order = order

        set_global_options header_height: 40
      end

      def define_columns
        column :order_number,           'Bestellnumer' ,                           width: 12
        column :article_name,           'Name',                                    width: 30
        column :article_unit,           'Einheit',                                 width: 10
        column :article_unit_quantity,  "Einheiten\npro\nGebinde",                 width: 10
        column :article_ordered,        "Bestellte\nEinheiten\nFoodsoft-\nNutzer", width: 10
        column :article_stock_quantity, "Einheiten in\nLager\nverfügbar",          width: 10
        column :article_units_to_order, "Gebinde bei\nProduzent\nbestellt",        width: 10
        column :article_gross_price,    "Bruttopreis\npro\nGebinde",               width: 10
        column :total_price,            "Total\nPreis",                           width: 10
      end

      def data
        overall_total_price = 0

        rows = @order.order_articles.map do |order_article|
          total_gross_price = order_article.total_gross_price
          overall_total_price += total_gross_price
          {
            order_number: order_article.article.order_number,
            article_name: order_article.article.name,
            article_unit: order_article.article.unit,
            article_unit_quantity: order_article.article.unit_quantity,
            article_ordered: order_article.quantity,
            article_stock_quantity: order_article.stock_quantity,
            article_units_to_order: order_article.units_to_order,
            article_gross_price: order_article.price.gross_price,
            total_price: total_gross_price
          }
        end

        rows << {
          order_number: 'Gesamtpreis',
          total_price: overall_total_price
        }

        rows
      end

      def post_process
        sheet.auto_filter = 'A1:I1'
      end
    end


    def generate_xls
      with_sheet @order.supplier.name, 9, :landscape, {} do |sheet|
        sheet.sheet_view.zoom_scale = 100
        sheet.sheet_view.show_white_space = true
        sheet.page_setup.scale = 70

        OrderSheet.new(sheet, @order).render

        package.workbook.add_defined_name(
          "&apos;0#{sheet.index + 1}&apos;!$1:$3",
          local_sheet_id: sheet.index, function: 'false', hidden: 'false', name: '_xlnm.Print_Titles'
        )
      end
    end
  end

end
