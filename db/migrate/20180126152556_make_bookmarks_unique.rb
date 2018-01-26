class MakeBookmarksUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :bookmarks, [ :user_id, :webpage_id ], unique: true
  end
end
