class Admin::Invitations::Bulk::DisablesController < AdminController
  before_action :set_invitation

  # DELETE /admin/invitation/bulk/disable
  def destroy
    bulk_results = @invitation.each_with_object({}) do |model, memo|
      memo[model.id] = model.update available: 0
    end

    all_good = bulk_results.values.all?

    if all_good
      flash[:info] = "Bulk delete of invitation was successful"
      render json: { bulk_results: bulk_results }, status: :ok
    else
      flash[:error] = "Some invitations could not be deleted"
      render json: { bulk_results: bulk_results }, status: :unprocessable_entity
    end
  end

  protected

  def bulk_params
    params.require(:bulk).permit(ids: [])
  end

  def set_invitation
    @invitation = Invitations.where id: bulk_params[:ids]
  end
end
