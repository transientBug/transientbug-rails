# frozen_string_literal: true

class BookmarkCardComponent < ViewComponent::Base
  def initialize(bookmark:)
    @bookmark = bookmark
  end
end
