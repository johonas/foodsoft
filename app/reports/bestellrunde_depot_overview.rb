module Reports
  class NoDataException < StandardError
  end

  class BestellrundeDepotOverview < Reporting::BaseExcelReport
    class Sheet < Reporting::TableXlsReport
      include GroupOrdersHelper
      include ApplicationHelper

      def initialize(sheet, bestellrunde, ordergroup)
        @bestellrunde = bestellrunde
        @ordergroup = ordergroup
        super(sheet)

        set_style :currency, { :alignment => { :horizontal => :left} }, :currency
      end

      def define_columns
        # TODO translate
        column :name, 'Name', :width => 55
        column :unit, 'Gebinde', :width => 13, :type => :string
        column :price, 'Einzelpreis', :width => 13, :style => :currency
        column :ordered, 'Bestellt', :width => 13, :type => :string
        column :total_price, 'Summe', :width => 13, :style => :currency
      end

      def header
        title = I18n.t('bestellrunde.show.title') % { :label => format_date(@bestellrunde.label) }
        sheet.add_row [title], style: styles.title
        sheet.add_row [@ordergroup.name], style: styles.subtytle
        sheet.add_row []
      end

      def data
        data = []
        @bestellrunde.aricles_by_group_order(@ordergroup).each do |order, suppliers|
          group_order = order.group_orders.where(:ordergroup => @ordergroup).first
          suppliers.each do |supplier, order_articles|
            order_articles.each do |oa|
              r = get_order_results(oa, group_order.id)

              quantity = r[:quantity]

              data << {
                :name => oa.article.name,
                :unit => "#{oa.price.unit_quantity} x #{oa.article.unit}",
                :price => oa.price.fc_price,
                :ordered => quantity,
                :total_price => r[:sub_total]
              }
            end
          end
        end

        return data.sort_by { |hsh| hsh[:name] }
      end

      def post_process
      end
    end

    def initialize(bestellrunde, ordergroup, filename)
      @bestellrunde = bestellrunde
      @ordergroup = ordergroup

      @filename = filename
      super()
    end

    def filename
      @filename
    end

    protected

    def generate_xls
      options = {
        page_margins: {
          top: cm2in(1.5),
          header: cm2in(0.8),
          left: cm2in(1),
          right: cm2in(1),
          bottom: cm2in(2),
          footer: cm2in(0.8)
        }
      }

      with_sheet @ordergroup.name, 9, :landscape, options do |sheet|
        Sheet.new(sheet, @bestellrunde, @ordergroup).render

        package.workbook.add_defined_name(
          "'#{@ordergroup.name}'!$4:$4",
          local_sheet_id: sheet.index, function: 'false', hidden: 'false', name: '_xlnm.Print_Titles'
        )
      end
    end
  end
end
