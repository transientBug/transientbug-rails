class AddPkToBookmarksTags < ActiveRecord::Migration[5.2]
  def change
    add_column :bookmarks_tags, :id, :primary_key
  end
end
