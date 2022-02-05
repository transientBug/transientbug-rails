class ConsolidateWebpageOnBookmarks < ActiveRecord::Migration[7.0]
  def change
    add_column :bookmarks, :uri, :text, null: false, default: ""
    add_index :bookmarks, :uri
  end
end
