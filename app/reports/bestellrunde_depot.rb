module Reports
  class BestellrundeDepot < Reports::BestellrundeBase
    class SupplierSheet < ProductSheet
      SHOW_PRODUCER = false
      def initialize(sheet, producer, depot, articles, ordergroups, bestellrunde)
        @depot = depot
        @producer = producer

        data = { ordergroups: ordergroups, articles: articles}
        super(sheet, data, bestellrunde)
        @fixed_cols = 2
        @first_data_row = 4
      end

      def define_columns
        column :product, 'Produkt', width: 35
        column :unit, 'Einheit', width: 8

        @ordergroups.each do |ordergroup|
          column ordergroup, ordergroup, :style => :quantity, :width => 3
        end

        column :sum, 'Total Depot', :style => :quantity, :width => 3
      end

      def header
        super
        sheet.add_row ["Produzent: #{@producer}"], style: styles.subtitle
      end

      def subtitle
        "Depot: #{@depot.name}"
      end
    end

    def initialize(bestellrunde, depot, filename)
      @bestellrunde = bestellrunde
      @depot = depot
      @filename = filename
      process_data
      super()
    end

    def filename
      @filename
    end

    protected

    def process_data
      raw_data = data[@depot]
      if raw_data
        # Group by producers
        raw_data[:articles] = raw_data[:articles].group_by { |d| d[:producer] }
        raw_data[:articles] = raw_data[:articles].sort.to_h
        @processed_data = raw_data
      else
        @processed_data = { articles: { 'blank' => [] }, ordergroups: [] }
      end
    end

    def generate_xls
      options = {
        page_margins: {
          top: cm2in(2),
          header: cm2in(1.1),
          left: cm2in(1),
          right: cm2in(1),
          bottom: cm2in(2),
          footer: cm2in(0.8)
        },
        header_footer: { different_first: false, odd_header: header, odd_footer: footer}
      }

      @processed_data[:articles].each do |producer, articles|
        sheet_name = producer.gsub(/\s+/, '')

        with_sheet sheet_name, 9, :landscape, options do |sheet|
          sheet.sheet_view.zoom_scale = 100
          sheet.sheet_view.show_white_space = true
          sheet.page_setup.scale = 70

          SupplierSheet.new(sheet, producer, @depot, articles, @processed_data[:ordergroups], @bestellrunde).render

          package.workbook.add_defined_name(
            "#{sheet_name}!$1:$4",
            local_sheet_id: sheet.index, function: 'false', hidden: 'false', name: '_xlnm.Print_Titles'
          )
        end
      end
    end
  end
end
