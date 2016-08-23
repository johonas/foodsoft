module Reports
  class Bestellrunde < Reports::BestellrundeBase
    class DepotSheet < ProductSheet
      def subtitle
        "QD: #{sheet.name}"
      end
    end

    def initialize(bestellrunde, filename)
      @bestellrunde = bestellrunde
      @filename = filename
      super()
    end

    protected

    def generate_xls
      options = {
        header_footer: { different_first: false, odd_header: header, odd_footer: footer}
      }

      data.each do |depot, depot_data|
        with_sheet depot.name, 9, :landscape, options do |sheet|
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
