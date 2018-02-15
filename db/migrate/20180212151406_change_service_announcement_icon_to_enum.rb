class ChangeServiceAnnouncementIconToEnum < ActiveRecord::Migration[5.2]
  def up
    ActiveRecord::Base.connection.execute <<~SQL
      CREATE TYPE icon AS ENUM ('announcement', 'help', 'info', 'warning', 'talk', 'settings', 'alarm', 'lab');
    SQL

    rename_column :service_announcements, :icon, :icon_text
    add_column :service_announcements, :icon, :icon
  end

  def down
    remove_column :service_announcements, :icon
    rename_column :service_announcements, :icon_text, :icon

    ActiveRecord::Base.connection.execute <<~SQL
      DROP TYPE icon;
    SQL
  end
end
