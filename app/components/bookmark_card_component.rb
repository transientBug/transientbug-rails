# frozen_string_literal: true

class BookmarkCardComponent < ViewComponent::Base
  with_collection_parameter :bookmark

  def initialize(bookmark:)
    @bookmark = bookmark
  end
end
