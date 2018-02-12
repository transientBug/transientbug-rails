class ChangeServiceAnnouncementColorToEnum < ActiveRecord::Migration[5.2]
  def change
    rename_column :service_announcements, :color, :color_text
    add_column :service_announcements, :color, :integer, default: 0
  end
end
