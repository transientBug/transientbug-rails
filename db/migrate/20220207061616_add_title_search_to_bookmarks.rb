class AddTitleSearchToBookmarks < ActiveRecord::Migration[7.0]
  def change
    change_table :bookmarks do |t|
      t.virtual :search_title, type: :tsvector, stored: true, as: "to_tsvector('english', coalesce(title, ''))"
      t.text :uri_breakdowns, array: true, default: []
    end

    add_index :bookmarks, :search_title, using: 'gin'
    add_index :bookmarks, :uri_breakdowns, using: 'gin'
  end
end
