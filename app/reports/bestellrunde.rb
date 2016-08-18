module Reports
  class Bestellrunde < Reporting::BaseExcelReport
    class DepotSheet < Reporting::TableXlsReport
      include ApplicationHelper

      FIXED_COLS = 3
      FIRST_DATA_ROW = 3

      def initialize(sheet, data, bestellrunde)
        super(sheet)

        set_global_options header_height: 90

        @ordergroups  = data[:ordergroups]
        @articles     = data[:articles]
        @bestellrunde = bestellrunde

        @ordergroups_count = @ordergroups.count

        set_style :tbl_bordered, { :sz => 9, :border => { :style => :thin, :color => '000000', :edges => [:top, :bottom, :left] } }

        set_style :column_header_vertical, { :alignment => { :textRotation => 90, :horizontal => :center },
                                             :border => { :style => :thin, :color => '000000', :edges => [ :left] }}, :column_header

        set_style :quantity, { :alignment => { :horizontal => :center } }, :tbl_bordered

        set_style :title, { b: true }
        set_style :subtitle, {}, :title
      end

      def define_columns
        column :product, 'Produkt', width: 35
        column :producer, 'HerstellerIn / LieferantIn', width: 22
        column :unit, 'Einheit', width: 10

        @ordergroups.each do |ordergroup|
          column ordergroup, ordergroup, :style => :quantity, :width => 3
        end

        column :sum, 'Total Depot', :style => :quantity, :width => 3
      end

      def data
        @articles
      end

      def header
        title = "foodcoop Comedor – Verteilliste: #{format_date(@bestellrunde.starts)} - #{format_date(@bestellrunde.ends)}"
        subtitle = "QD: #{sheet.name}"

        sheet.add_row [title], style: styles.title
        sheet.add_row [subtitle], style: styles.subtitle
      end

      def post_process
        # set column headers
        (@ordergroups_count + 1).times do |ordergroup_index|
          sheet.rows[FIRST_DATA_ROW - 1].cells[FIXED_COLS + ordergroup_index].style = styles.column_header_vertical
        end

        @articles.count.times.each do |article_index|
          from = XLS_APHABET[FIXED_COLS]
          to = XLS_APHABET[FIXED_COLS + @ordergroups_count - 1]

          row_index = FIRST_DATA_ROW + article_index

          value = "=SUM(#{from}#{row_index + 1}:#{to}#{row_index + 1})"
          sheet.rows[row_index].cells[FIXED_COLS + @ordergroups_count].value = value
        end
      end
    end

    def initialize(bestellrunde, filename)
      @bestellrunde = bestellrunde
      @filename = filename
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

          depot = group_order.ordergroup.depot

          raw_data[depot] ||= {}
          group_order.group_order_articles.each do |group_order_article|
            article = group_order_article.order_article.article

            raw_data[depot][article] ||= {}
            raw_data[depot][article][group_order.ordergroup] = group_order_article.result
          end
        end
      end


      raw_data.each do |depot, articles|
        data[depot.name] = {}
        data[depot.name][:ordergroups] = Set.new
        data[depot.name][:articles]    = []

        articles.each do |article, ordergroups|
          article_row = {}
          article_row[:product] = article.name
          article_row[:producer] = article.supplier.name
          article_row[:unit] = article.unit

          ordergroups.each do |ordergroup, amount|
            article_row[ordergroup.name] = amount
            data[depot.name][:ordergroups] << ordergroup.name
          end

          data[depot.name][:articles] << article_row
        end
      end

      return data
    end

    def generate_xls
      options = {
        header_footer: { different_first: false, odd_header: header, odd_footer: footer}
      }

      data.each do |depot_name, depot_data|
        with_sheet depot_name, 9, :landscape, options do |sheet|
          sheet.sheet_view.zoom_scale = 100
          sheet.sheet_view.show_white_space = true
          sheet.page_setup.scale = 70

          DepotSheet.new(sheet, depot_data, @bestellrunde).render

          package.workbook.add_defined_name(
            "&apos;0#{sheet.index + 1}&apos;!$1:$3",
            local_sheet_id: sheet.index, function: 'false', hidden: 'false', name: '_xlnm.Print_Titles'
          )
        end
      end
    end
  end
end
