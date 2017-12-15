class CreateClockworkDatabaseEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :clockwork_database_events do |t|
      t.integer :frequency_quantity
      t.integer :frequency_period
      t.string :at

      t.string :job_name
      t.jsonb :job_arguments

      t.timestamps
    end
  end
end
