class Admin::ApplicationsController < AdminController
  before_action :set_application, only: [:show, :edit, :update, :destroy]

  # GET /admin/applications
  def index
    @applications = Doorkeeper::Application.all.page params[:page]
  end

  # GET /admin/applications/1
  def show; end

  # GET /admin/applications/1/edit
  def edit; end

  # PATCH/PUT /admin/applications/1
  def update
    respond_to do |format|
      if @application.update(application_params)
        format.html { redirect_to admin_application_path(@application), notice: 'Application was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /admin/applications/1
  def destroy
    @application.destroy
    respond_to do |format|
      format.html { redirect_to admin_applications_url, notice: 'Application was successfully destroyed.' }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_application
    @application = Doorkeeper::Application.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def application_params
    params.fetch(:application, {})
  end
end
