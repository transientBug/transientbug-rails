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
      tags = entry["tags"].split(",").map(&:chomp)

      Bookmark.for(@import_data.user, entry["href"]).tap do |bookmark|
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
      end.upsert
    end

    import_data.update complete: true
    # TODO: Imported notification?
  end
end
