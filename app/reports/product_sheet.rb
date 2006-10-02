module Reports
  class ProductSheet < Reporting::TableXlsReport
    include ApplicationHelper

    def initialize(sheet, data, bestellrunde, hide: [])
      super(sheet)

      @fixed_cols = 4
      @first_data_row = 2 + subtitle.length

      @fixed_cols -= hide.length

      set_global_options header_height: 90

      @articles     = data[:articles]
      @bestellrunde = bestellrunde
      @hide = hide

      @ordergroups = []
      data[:ordergroups].each do |ordergroup|
        if @articles.any?{ |article| article[ordergroup] }
          @ordergroups << ordergroup
        end
      end


      @ordergroups_count = @ordergroups.count

      set_style :tbl_bordered, { :sz => 9, :border => { :style => :thin, :color => '000000', :edges => [:top, :bottom, :left] } }

      set_style :column_header_vertical_nb, { :alignment => { :textRotation => 90, :horizontal => :center } }, :column_header
      set_style :column_header_vertical, { :border => { :style => :thin, :color => '000000', :edges => [ :left] }}, :column_header_vertical_nb

      set_style :quantity, { :alignment => { :horizontal => :left } }, :tbl_bordered

      set_style :stock, { :alignment => { :horizontal => :center } }, :bordered

      set_style :title, { b: true }
      set_style :subtitle, {}, :title
    end

    def define_columns
      column :product, 'Produkt', width: 35 unless @hide.include?(:product)
      column :stock, 'Lager', width: 3, :style => :stock unless @hide.include?(:stock)
      column :supplier, 'HerstellerIn / LieferantIn', width: 22 unless @hide.include?(:supplier)
      column :unit, 'Einheit', width: 10 unless @hide.include?(:unit)

      @ordergroups.each do |ordergroup|
        column ordergroup, ordergroup, :style => :quantity, :width => 3
      end

      column :sum, 'Total Depot', :style => :quantity, :width => 3
    end

    def data
      @articles
    end

    def header
      sheet.add_row [title], style: styles.title
      subtitle.each do |line|
        sheet.add_row [line], style: styles.subtitle
      end
    end

    def title
      "foodcoop Comedor – Verteilliste: #{format_date(@bestellrunde.starts)} - #{format_date(@bestellrunde.ends)}"
    end

    def subtitle
      []
    end

    def post_process
      # set column headers
      sheet.rows[@first_data_row - 1].cells[1].style = styles.column_header_vertical_nb

      (@ordergroups_count + 1).times do |ordergroup_index|
        cell_index = @fixed_cols + ordergroup_index
        sheet.rows[@first_data_row - 1].cells[cell_index].style = styles.column_header_vertical
      end

      @articles.count.times.each do |article_index|
        from = XLS_APHABET[@fixed_cols]
        to = XLS_APHABET[@fixed_cols + @ordergroups_count - 1]

        row_index = @first_data_row + article_index

        value = "=SUM(#{from}#{row_index + 1}:#{to}#{row_index + 1})"
        sheet.rows[row_index].cells[@fixed_cols + @ordergroups_count].value = value
      end
    end
  end
end
