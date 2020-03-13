# frozen_string_literal: true

class ImportData::PinboardJob < ImportData::BaseJob
  def parse_file
    JSON.parse import_data.upload.download
  end

  def parse_entry entry
    raw_tags = entry["tags"].split(",").map(&:chomp)
    tags = Tag.find_or_create_tags tags: raw_tags

    created_at = Time.zone.parse entry["time"]

    # See also https://pinboard.in/api/#posts_add
    #
    # > description: Title of the item. This field is unfortunately named
    #   'description' for backwards compatibility with the delicious API
    #
    # > extended: Description of the item. Called 'extended' for backwards
    #   compatibility with delicious API
    [
      entry["href"],
      {
        title: entry["description"],
        description: entry["extended"],
        tags: tags
      },
      created_at
    ]
  end
end
