class CreateSearches < ActiveRecord::Migration[5.2]
  def change
    create_table :searches do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.text :description
      t.jsonb :query

      t.timestamps
    end
  end
end
