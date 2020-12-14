require "zlib"
require "rubygems/package"

namespace :photos do
  task export: :environment do
    Image.each do |img|
    end
  end
end
