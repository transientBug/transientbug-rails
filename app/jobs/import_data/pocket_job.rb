class ImportData::PocketJob < ImportData::BaseJob
  def parse_file
    nokogiri = Nokogiri::HTML import_data.upload.blob.download

    nokogiri.search("li").map(&:child)
  end

  def parse_entry entry
    raw_tags = entry["tags"].split(",").map(&:chomp)
    tags = Tag.find_or_create_tags tags: raw_tags

    created_at = Time.at entry["time_added"].to_i

    # Pocket doesn't have a concept of descriptions, only title and tags
    [
      entry["href"],
      {
        title: entry.inner_text,
        tags: tags
      },
      created_at
    ]
  end
end
