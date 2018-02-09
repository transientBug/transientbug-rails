class Admin::ServiceAnnouncements::Bulk::DeletesController < AdminController
  before_action :set_service_announcement

  # DELETE /admin/service_announcement/bulk/delete
  def destroy
    bulk_results = @service_announcement.each_with_object({}) do |model, memo|
      memo[model.id] = model.destroy
    end

    all_good = bulk_results.values.all?

    if all_good
      flash[:info] = "Bulk delete of service announcements was successful"
      render json: { bulk_results: bulk_results }, status: :ok
    else
      flash[:error] = "Some service announcements could not be deleted"
      render json: { bulk_results: bulk_results }, status: :unprocessable_entity
    end
  end

  protected

  def bulk_params
    params.require(:bulk).permit(ids: [])
  end

  def set_service_announcement
    @service_announcement = ServiceAnnouncement.where id: bulk_params[:ids]
  end
end
