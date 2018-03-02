class CreateErrorMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :error_messages do |t|
      t.string :key
      t.text :message

      t.timestamps
    end
  end
end
