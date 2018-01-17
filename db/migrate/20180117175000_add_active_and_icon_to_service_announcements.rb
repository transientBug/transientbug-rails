class AddActiveAndIconToServiceAnnouncements < ActiveRecord::Migration[5.2]
  def change
    add_column :service_announcements, :icon, :text
    add_column :service_announcements, :active, :boolean, default: true
  end
end
