class ImportData::PinboardJob < ApplicationJob
  queue_as :default
  attr_reader :import_data

  def perform import_data:
    @import_data = import_data

    parse_file
  end

  private

  def parse_file
    json_data = JSON.parse @import_data.upload.download

    json_data.each do |entry|
      href = entry["href"]
      tags = entry["tags"].split(",").map(&:chomp)
      created_at = Time.parse entry["time"]

      Bookmark.for(@import_data.user, href).tap do |bookmark|
        # See also https://pinboard.in/api/#posts_add
        #
        # > description: Title of the item. This field is unfortunately named
        #   'description' for backwards compatibility with the delicious API
        #
        # > extended: Description of the item. Called 'extended' for backwards
        #   compatibility with delicious API
        bookmark.title       = entry["description"]
        bookmark.description = entry["extended"]

        bookmark.tags = Tag.find_or_create_tags(tags: tags)

        bookmark.created_at = created_at if boookmark.new_record?
      end.upsert
    end

    import_data.update complete: true
    # TODO: Imported notification?
  end
end
