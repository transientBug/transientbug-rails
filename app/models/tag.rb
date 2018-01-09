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

  before_validation :set_color

  validates :label, presence: true

  update_index("bookmarks#tag") { self }

  private

  def set_color
    self.color ||= COLORS[ label.length % COLORS.length ]
  end
end
