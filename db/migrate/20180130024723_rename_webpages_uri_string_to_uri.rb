class RenameWebpagesUriStringToUri < ActiveRecord::Migration[5.2]
  def change
    rename_column :webpages, :uri_string, :uri
  end
end
