module Reporting
  class BaseReport
    def generate
      raise NotImplementedError
    end

    def send(controller)
      controller.send_data @bytes, :content_type => content_type, :filename => filename
    end

    def filename
      raise NotImplementedError
    end

    def content_type
      raise NotImplementedError
    end
  end
end