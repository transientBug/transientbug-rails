class BookmarkSearcher < ApplicationSearcher
  index BookmarksIndex::Bookmark

  keyword :title
  keyword :description

  keyword :tags, aliases: [ :tag ]

  keyword :uri

  keyword :host

  def fetch result
    Bookmark.where id: result.pluck(:_id)
  end
end
