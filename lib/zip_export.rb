require 'zip'

class ZipExport
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def content_type
    'application/zip'
  end

  def zip_name
    "#{@filename}.zip"
  end

  def data
    create_temp_dir
    render_files
    create_zip

    File.read(@zipfile_name)
  ensure
    FileUtils.rm_rf(@zip_dir)
  end

  def render_files
    fail 'Not implemented'
  end

  def add_file(file)
    @files ||= []
    @files << file
  end

  def create_temp_dir
    @zip_dir = Rails.root.join('tmp', 'zip', "#{@filename}_#{SecureRandom.urlsafe_base64}").to_s
    @temp_dir = Rails.root.join(@zip_dir, @filename).to_s
    FileUtils.mkdir_p(@temp_dir)
  end

  def create_zip
    @zipfile_name = Rails.root.join(@zip_dir, zip_name).to_s

    Zip::File.open(@zipfile_name, Zip::File::CREATE) do |zipfile|
      Dir[File.join(@temp_dir, '*')].each do |file|
        local_path = File.join(@filename, File.basename(file))
        zipfile.add(local_path, file)
      end
    end
  end
end
