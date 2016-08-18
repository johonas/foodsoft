module Reporting
  class BaseExcelReport < BaseReport
    attr_reader :path
    attr_reader :bytes

    def initialize
      @package = Axlsx::Package.new
      @package.workbook.use_shared_strings = false
    end

    def generate_xls
      raise NotImplementedError
    end

    def filename
      raise NotImplementedError
    end

    def with_sheet(name, size, orientation, worksheet_options = {}, &block)
      package.workbook.add_worksheet(worksheet_options.merge(name: name)) do |sheet|
        sheet.page_setup do |page|
          page.paper_size = size
          page.orientation = orientation
        end

        yield sheet
      end
    end

    def generate
      generate_xls

      stream = @package.to_stream
      @bytes = stream.read
      stream.close

      return self
    end

    def content_type
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    end

    protected

    attr_reader :package
  end
end