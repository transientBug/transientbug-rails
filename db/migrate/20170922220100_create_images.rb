class CreateImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images do |t|
      t.references :user, foreign_key: true
      t.text :title
      t.text :tags, array: true, default: []
      t.text :source

      t.timestamps
    end
  end
end
