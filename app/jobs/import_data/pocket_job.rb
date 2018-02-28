class ImportData::PocketJob < ApplicationJob
  queue_as :default
  attr_reader :import_data

  def perform import_data:
    @import_data = import_data

    parse_file
  end

  private

  def parse_file
    nokogiri = Nokogiri::XML.parse import_data.upload.blob.download

    nokogiri.search("li").each do |node|
      anchor_child = node.child

      href = anchor_child["href"]
      tags = anchor_child["tags"].split(",").map(&:chomp)
      created_at = Time.at anchor_child["time_at"].to_i

      Bookmark.for(@import_data.user, href).tap do |bookmark|
        # Pocket doesn't have a concept of descriptions, only title and tags
        bookmark.title = anchor_child.inner_text

        bookmark.tags = Tag.find_or_create_tags(tags: tags)

        bookmark.created_at = created_at if bookmark.new_record?
      end.upsert
    end

    import_data.update complete: true
    # TODO: Imported notification?
  end
end
