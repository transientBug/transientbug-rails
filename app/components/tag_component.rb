# frozen_string_literal: true

class TagComponent < ViewComponent::Base
  def initialize(tag:)
    @tag = tag
  end

  def color
    {
    }.fetch tag.color, "bg-limegreen-500"
  end
end
