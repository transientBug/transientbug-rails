class Admin::ServiceAnnouncements::Bulk::DeactivatesController < AdminController
  before_action :set_service_announcements

  # PATCH /admin/service_announcement/bulk/deactivate
  # PUT /admin/service_announcement/bulk/deactivate
  def update
    bulk_results = @service_announcements.each_with_object({}) do |model, memo|
      memo[model.id] = model.update active: false
    end

    all_good = bulk_results.values.all?

    if all_good
      flash[:info] = "Bulk deactivation of service announcements was successful"
      render json: { bulk_results: bulk_results }, status: :ok
    else
      flash[:error] = "Some service announcements could not be deactivated"
      render json: { bulk_results: bulk_results }, status: :unprocessable_entity
    end
  end

  protected

  def bulk_params
    params.require(:bulk).permit(ids: [])
  end

  def set_service_announcements
    @service_announcements = ServiceAnnouncement.where id: bulk_params[:ids]
  end
end
