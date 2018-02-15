class ChangeServiceAnnouncementColorToEnum < ActiveRecord::Migration[5.2]
  def up
    ActiveRecord::Base.connection.execute <<~SQL
      CREATE TYPE color AS ENUM ('plain', 'red', 'orange', 'yellow', 'olive', 'green', 'teal', 'blue', 'violet', 'purple', 'pink', 'brown', 'grey', 'black');
    SQL

    rename_column :service_announcements, :color, :color_text
    add_column :service_announcements, :color, :color
  end

  def down
    remove_column :service_announcements, :color
    rename_column :service_announcements, :color_text, :color

    ActiveRecord::Base.connection.execute <<~SQL
      DROP TYPE color;
    SQL
  end
end
