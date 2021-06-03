# frozen_string_literal: true

class TagComponent < ViewComponent::Base
  def initialize tag:
    @tag = tag
  end

  def color
    {
      red: :red,
      orange: :orange,
      yellow: :yellow,
      olive: :olive,
      green: :limegreen,
      teal: :teal,
      blue: :blue,
      violet: :violet,
      purple: :purple,
      pink: :pink,
      brown: :brown,
      grey: :gray,
      black: :gray
    }.transform_keys(&:to_s).fetch tag.color, "limegreen"
  end
end
