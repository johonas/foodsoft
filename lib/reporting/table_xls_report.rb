module Reporting
  class TableXlsReport
    BG_COLOR_GROUP_SUM = 'b2b2b2'
    BG_COLOR_TOTAL_SUM = '838383'
    FG_COLOR_TOTAL_SUM = 'FFFFFF'

    XLS_APHABET = ("A".."Z").to_a + ("AA".."ZZ").to_a

    attr_reader :sheet, :styles, :style_definitions, :columns

    def initialize(sheet)
      @sheet = sheet
      @styles = OpenStruct.new
      @style_definitions = {}
      @global_options = {}

      set_style :bordered,      { :sz => 9, :border => { :style => :thin, :color => '000000', :edges => [:top, :bottom] } }
      set_style :title,         { :sz => 15 }
      set_style :column_header, { :b => true }
      set_style :percentage,    { :format_code => '0.0 \%' },     :bordered
      set_style :date,          { :format_code => 'dd.mm.yyyy' }, :bordered
      set_style :integer,       { :format_code => '#,##0' },      :bordered

      set_style :group_sum,     { :bg_color => BG_COLOR_GROUP_SUM, :b => true },                                  :bordered
      set_style :total_sum,     { :bg_color => BG_COLOR_TOTAL_SUM, :b => true, :fg_color => FG_COLOR_TOTAL_SUM }, :bordered
      set_style :footnote, { :sz => 8 }
    end

    def set_global_options(options)
      default_options = { header_height: 20 }
      @global_options = default_options.merge(options)
    end

    def column(key, label, options={})
      column = OpenStruct.new(key: key, label: label, options: OpenStruct.new(options))
      @columns ||= []
      @columns << column
    end

    def render(options={})
      define_columns

      data = self.data
      total_sum = columns.any? { |c| c.options.total_sum }

      # ---------------------------------------------------------------
      # Header
      # ---------------------------------------------------------------
      header

      # ---------------------------------------------------------------
      # Draw column headers
      # ---------------------------------------------------------------
      header_styles =  columns.collect { |c| styles.column_header }
      sheet.add_row columns.collect { |c| c.label }, :style => header_styles, height: @global_options[:header_height]

      # ---------------------------------------------------------------
      # Freeze a header row (optional)
      # ---------------------------------------------------------------
      if options[:freeze_row]
        sheet.sheet_view.pane do |pane|
          pane.top_left_cell = "A#{options[:freeze_row] + 1}"
          pane.state = :frozen_split
          pane.y_split = options[:freeze_row]
          pane.x_split = 0
          pane.active_pane = :bottom_right
        end
      end

      # ---------------------------------------------------------------
      # Render data
      # ---------------------------------------------------------------
      render_records data

      # ---------------------------------------------------------------
      # Total sum
      # ---------------------------------------------------------------
      first_row_offset = sheet.rows.size + 1
      last_row_offset = sheet.rows.size

      if total_sum
        row_data = []
        row_styles = []

        columns.each_with_index do |column, idx|
          if idx == 0
            # Total not allowed for first column
            row_data << 'Grand Total:'
          elsif column.options.total_sum
            row_data << "=SUBTOTAL(9,#{XLS_APHABET[idx]}#{first_row_offset}:#{XLS_APHABET[idx]}#{last_row_offset})"
          else
            row_data << ''
          end

          row_styles << get_anonymous_style(:total_sum, column.options.style)
        end

        sheet.add_row row_data, :style => row_styles unless data.blank?
      end

      if data.blank?
        row = sheet.rows.size
        sheet.merge_cells "A#{row+1}:#{XLS_APHABET[columns.size-1]}#{row+1}"
        sheet.add_row ["This report contains no data."]
      end

      # ---------------------------------------------------------------
      # Footer
      # ---------------------------------------------------------------
      footer

      # ---------------------------------------------------------------
      # Set column widths
      # ---------------------------------------------------------------
      sheet.column_widths *columns.collect { |c| c.options.width }

      # ---------------------------------------------------------------
      # Hide column
      # ---------------------------------------------------------------
      columns.each_with_index do |column, idx|
        sheet.column_info[idx].hidden = true if column.options.hidden
      end

      post_process
    end

    protected

    def define_columns
      raise NotImplementedError
    end

    def data
      raise NotImplementedError
    end

    def post_process
      raise NotImplementedError
    end

    def header
    end

    def footer
    end

    def set_style(key, definition, based_on=nil)
      if based_on.is_a?(Symbol)
        definition = style_definitions[based_on].merge(definition)
      elsif based_on.is_a?(Hash)
        definition = based_on.merge(definition)
      end

      style_definitions[key] = definition
      styles.send "#{key}=", sheet.styles.add_style(definition)
    end


    def get_anonymous_style(key1, key2)
      return styles.send(key1) if key2.nil?
      sheet.styles.add_style(style_definitions[key1].merge(style_definitions[key2]))
    end

    private

    def render_records(records)
      records.each do |record|
        row_data = []
        row_styles = []
        row_types = []

        columns.each do |column|
          if record.is_a?(Hash)
            row_data << record[column.key]
          elsif record.respond_to?(column.key)
            row_data << record.send(column.key)
          else
            row_data << ''
          end

          if record[:style]
            row_styles << get_anonymous_style(record[:style], column.options.style)
          else
            row_styles << resolve_column_style(column)
          end

          row_types << resolve_column_type(column)
        end

        sheet.add_row row_data, :style => row_styles, :types => row_types
      end
    end

    def resolve_column_style(column)
      if column.options.style.is_a?(Symbol)
        return styles.send(column.options.style)
      elsif column.options.style.nil?
        return styles.bordered
      else
        raise 'Style not supported.'
      end
    end

    def resolve_column_type(column)
      if column.options.type.is_a?(Symbol) || column.options.type.nil?
        return column.options.type
      else
        raise 'Type not supported.'
      end
    end
  end
end
