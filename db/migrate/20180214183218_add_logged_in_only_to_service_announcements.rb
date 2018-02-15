class AddLoggedInOnlyToServiceAnnouncements < ActiveRecord::Migration[5.2]
  def change
    add_column :service_announcements, :logged_in_only, :boolean, default: false
  end
end
