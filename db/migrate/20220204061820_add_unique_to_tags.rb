class AddUniqueToTags < ActiveRecord::Migration[7.0]
  def change
    add_index :tags, :label, unique: true
  end
end
