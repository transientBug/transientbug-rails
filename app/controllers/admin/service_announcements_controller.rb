class Admin::ServiceAnnouncementsController < AdminController
  before_action :set_count
  before_action :set_service_announcement, only: [:show, :edit, :update, :destroy]

  # GET /service_announcements
  def index
    @service_announcements = ServiceAnnouncement.unscoped.all.order(created_at: :desc).page params[:page]
  end

  # GET /service_announcements/1
  def show
  end

  # GET /service_announcements/new
  def new
    @service_announcement = ServiceAnnouncement.new
  end

  # POST /service_announcements
  def create
    @service_announcement = ServiceAnnouncement.new service_announcement_params

    respond_to do |format|
      if @service_announcement.save
        format.html { redirect_to [:admin, @service_announcement], notice: "Service Announcement was successfully created." }
      else
        format.html { render :new }
      end
    end
  end

  # GET /service_announcements/1/edit
  def edit
  end

  # PATCH/PUT /service_announcements/1
  def update
    respond_to do |format|
      if @service_announcement.update(service_announcement_params)
        format.html { redirect_to [:admin, @service_announcement], notice: "Service Announcement was successfully updated." }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /service_announcements/1
  def destroy
    respond_to do |format|
      if @service_announcement.destroy
        format.html { redirect_to admin_service_announcements_url, notice: "Service Announcement was successfully deleted." }
      else
        format.html { render :new }
      end
    end
  end

  private

  def set_service_announcement
    @service_announcement = ServiceAnnouncement.unscoped.find params[:id]
  end

  def set_count
    @count = ServiceAnnouncement.count
  end

  def service_announcement_params
    params.require(:service_announcement).permit(:title, :message, :color, :icon, :start_at, :end_at, :active)
  end
end
