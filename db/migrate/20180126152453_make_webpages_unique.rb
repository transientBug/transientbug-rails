class MakeWebpagesUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :webpages, :uri_string, unique: true
  end
end
