class CreateBookmarks < ActiveRecord::Migration[5.2]
  def change
    create_table :bookmarks do |t|
      t.references :user, foreign_key: true
      t.references :webpage, foreign_key: true

      t.text :title
      t.text :description

      t.timestamps
    end
  end
end
