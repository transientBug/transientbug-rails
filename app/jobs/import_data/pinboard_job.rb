class ImportData::PinboardJob < ApplicationJob
  queue_as :default
  attr_reader :import_data

  def perform import_data:
    @import_data = import_data

    parse_file
  end

  private

  def parse_file
    @nokogiri = Nokogiri::XML.parse import_data.upload.blob.download

    binding.pry
  end
end
