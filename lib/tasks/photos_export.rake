require "zlib"
require "rubygems/package"

namespace :photos do
  task export: :environment do
    output ||= Pathname.new("../images/export.tar.gz").tap do |path|
      path.parent.mkpath
    end

    tar_handle = Tempfile.new "photos"
    tar_handle.binmode
    tar_writter = Gem::Package::TarWriter.new tar_handle

    Image.all.each do |img|
      filename = img.image_blob.filename

      tar_writter.add_file "#{ filename }", 777 do |tar_io|
        img.image_blob.open do |tmp|
          tmp.binmode
          tar_io.write tmp.read
        end
      end

      sidecar = {
        filename:,
        blob: img.image_blob.as_json,
        record: img.as_json
      }

      tar_writter.add_file "#{ filename }.json", 777 do |tar_io|
        tar_io.write sidecar.to_json
      end

      puts "Wrote #{ filename }(.json) for image #{ img.id }"
    rescue ActiveStorage::FileNotFoundError
      puts "Can't find file for the blob for image #{ img.id }!"
    end

    tar_writter.flush
    tar_handle.rewind

    Zlib::GzipWriter.open(output) do |gz|
      gz.orig_name = "photos"
      gz.write tar_handle.read
    end

    tar_writter.close
    tar_handle.close
    tar_handle.unlink
  end

  task clearout: :environment do
    Image.all.each(&:destroy)
  end
end
