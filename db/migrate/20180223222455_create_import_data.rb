class CreateImportData < ActiveRecord::Migration[5.2]
  def up
    ActiveRecord::Base.connection.execute <<~SQL
      CREATE TYPE import_type AS ENUM ('pinboard', 'pocket');
    SQL

    create_table :import_data do |t|
      t.references :user, foreign_key: true

      t.column :import_type, :import_type

      t.boolean :complete, default: false

      t.timestamps
    end

    create_join_table :import_data, :error_messages
  end

  def down
    drop_join_table :import_data, :error_messages
    drop_table :import_data

    ActiveRecord::Base.connection.execute <<~SQL
      DROP TYPE import_type;
    SQL
  end
end
