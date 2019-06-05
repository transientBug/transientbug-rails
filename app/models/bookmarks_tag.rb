class BookmarksTag < ApplicationRecord
  belongs_to :bookmark
  belongs_to :tag

  update_index("bookmarks#bookmark") { self.bookmark }
end
