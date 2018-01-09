class AddUriStringToBookmarks < ActiveRecord::Migration[5.2]
  def change
    add_column :bookmarks, :uri_string, :string
  end
end
