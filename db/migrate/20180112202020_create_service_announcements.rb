class CreateServiceAnnouncements < ActiveRecord::Migration[5.2]
  def change
    create_table :service_announcements do |t|
      t.text :title
      t.text :message
      t.text :color
      t.timestamp :start_at
      t.timestamp :end_at

      t.timestamps
    end
  end
end
