class Tag < ApplicationRecord
  COLORS = [
    :red,
    :orange,
    :yellow,
    :olive,
    :green,
    :teal,
    :blue,
    :violet,
    :purple,
    :pink,
    :brown,
    :grey,
    :black
  ].freeze

  after_initialize :set_color

  validates :label, presence: true, uniqueness: true

  update_index("bookmarks#tag") { self }

  def self.find_or_create_tags tags: []
    tags.map do |tag|
      next tag if tag.is_a? Tag
      next if tag.empty?

      upsert label: tag.strip
    end.compact
  end

  private

  def set_color
    self.color ||= COLORS[ label.length % COLORS.length ]
  end
end
