require "zlib"
require "rubygems/package"

namespace :phots do
  task :import, [:user_id, :images, :dump] => [ :environment ] do |t, args|
    Importer.new(args[:user_id], args[:images], args[:dump]).run
  end
end

class Importer
  attr_reader :user_id, :images, :dump

  def initialize user_id, images, dump
    @user_id = user_id
    @images = images
    @dump = dump
  end

  def dump_path
    @dump_path ||= Pathname.new dump
  end

  def images_tar_handle
    @images_tar_handle ||= Zlib::GzipReader .open images
  end

  def images_tar_reader
    @images_tar_reader ||= Gem::Package::TarReader.new images_tar_handle
  end

  def dump_tar_handle
    @dump_tar_handle ||= Zlib::GzipReader.open dump
  end

  def dump_tar_reader
    @dump_tar_reader ||= Gem::Package::TarReader.new dump_tar_handle
  end

  def images_data
    @images_data ||= dump_tar_reader.seek "#{ dump_path.basename.sub_ext("").sub_ext("").to_s }/app/phots.json" do |entry|
      JSON.parse entry.read, symbolize_names: true
    end
  end

  def user
    @user ||= User.find user_id
  end

  def run
    images_data.each do |phot|
      images_tar_reader.seek "var/www/bug/html/i/#{ phot[:filename] }" do |entry|
        tags = phot[:tags].map { |tag| tag.gsub("_", " ") }

        image = user.images.new title: phot[:title], tags: tags, source: phot[:url], disabled: !!phot[:disable]

        puts "failed on #{ phot[:filename] }" unless image.save

        io = Tempfile.new phot[:filename]
        io.binmode
        io.write entry.read
        io.rewind

        image.image.attach io: io, filename: phot[:filename]

        print "."
      end
    end
  end
end
