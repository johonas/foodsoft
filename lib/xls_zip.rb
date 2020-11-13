class XlsZip < ZipExport
  def render_files
    @files.each do |xls|
      xls_filename = Rails.root.join(@temp_dir, xls.filename)
      File.open(xls_filename, 'wb') do |file|
        file.write(xls.bytes)
      end
    end
  end
end
