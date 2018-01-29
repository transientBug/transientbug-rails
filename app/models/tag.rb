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
    tags.map(&:strip).reject(&:empty?).map do |tag|
      next tag if tag.is_a? Tag

      upsert label: tag
    end
  end

  private

  def set_color
    self.color ||= COLORS[ label.length % COLORS.length ]
  end
end
