class Admin::ServiceAnnouncements::ToggleController < AdminController
  before_action :set_service_announcement

  # POST /admin/service_announcements/1/toggle
  def create
    respond_to do |format|
      if @service_announcement.update active: !@service_announcement.active
        format.html { redirect_to admin_service_announcement_path(@service_announcement), notice: "Active Toggled" }
      else
        format.html { render "admin/service_announcements/show" }
      end
    end
  end

  private

  def set_service_announcement
    @service_announcement = ServiceAnnouncement.find params[:service_announcement_id]
  end
end
