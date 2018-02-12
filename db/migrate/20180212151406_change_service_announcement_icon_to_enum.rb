class ChangeServiceAnnouncementIconToEnum < ActiveRecord::Migration[5.2]
  def change
    rename_column :service_announcements, :icon, :icon_text
    add_column :service_announcements, :icon, :integer, default: 0
  end
end
