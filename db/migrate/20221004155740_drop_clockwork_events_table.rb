class DropClockworkEventsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :clockwork_database_events
  end
end
