# frozen_string_literal: true

module ImagesHelper
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

  def color_for string
    COLORS[ string.length % COLORS.length ]
  end
end
