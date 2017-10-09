module Reports
  class ProductSheet < Reporting::TableXlsReport
    include ApplicationHelper

    ODD_COLOR = 'DCE6F1'

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

      set_style :column_header_vertical, { :alignment => { :textRotation => 90, :horizontal => :right } }, :column_header

      set_style :quantity, { :alignment => { :horizontal => :right } }, :bordered
      set_style :total, { :b => true }, :quantity
      set_style :total_odd, { :b => true, :bg_color => ODD_COLOR }, :quantity

      set_style :stock_header, { :alignment => { :horizontal => :left } }, :column_header_vertical
      set_style :stock, { :alignment => { :horizontal => :left } }, :bordered

      set_style :stock_active, { :bg_color => 'E2E2E2' }, :bordered
      set_style :total_stock_active, { :b => true }, :stock_active


      set_style :title, { b: true }
      set_style :subtitle, {}, :title

      set_style :row_odd, { :bg_color => ODD_COLOR }, :bordered

    end

    def define_columns
      column :product, 'Produkt', width: 35 unless @hide.include?(:product)
      column :stock, 'Lager', width: 3, :style => :stock unless @hide.include?(:stock)
      column :supplier, 'HerstellerIn / LieferantIn', width: 22 unless @hide.include?(:supplier)
      column :unit, 'Einheit', width: 10 unless @hide.include?(:unit)

      @ordergroups.each do |ordergroup|
        column ordergroup, ordergroup, :style => :quantity, :width => 3
      end

      column :sum, 'Total Depot', :style => :total, :width => 3
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
      sheet.rows[@first_data_row - 1].cells[1].style = styles.stock_header

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

        # Set background color
        if (row_index % 2 != 0)
          colorize_row(row_index,styles.row_odd, styles.total_odd)
        end

        if sheet.rows[row_index].cells[1].value == 'x'
          colorize_row(row_index,styles.stock_active, styles.total_stock_active)
        end
      end
    end

    def colorize_row(row_index, odd_style, total_style)
      (@fixed_cols + @ordergroups_count).times do |c_index|
        sheet.rows[row_index].cells[c_index].style = odd_style
      end
      sheet.rows[row_index].cells[@fixed_cols + @ordergroups_count].style = total_style
    end
  end
end
