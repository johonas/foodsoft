class PdfZip < ZipExport
  def render_files
    @files.each do |pdf|
      pdf_filename = Rails.root.join(@temp_dir, pdf.filename)
      File.open(pdf_filename, 'wb') do |file|
        file.write(pdf.to_pdf)
      end
    end
  end
end
