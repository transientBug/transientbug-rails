class Admin::Invitations::Bulk::DisablesController < AdminController
  before_action :set_invitation

  # PATCH /admin/invitation/bulk/disable
  # PUT /admin/invitation/bulk/disable
  def update
    bulk_results = @invitation.each_with_object({}) do |model, memo|
      memo[model.id] = model.update available: 0
    end

    all_good = bulk_results.values.all?

    if all_good
      flash[:info] = "Bulk disable of invitations was successful"
      render json: { bulk_results: bulk_results }, status: :ok
    else
      flash[:error] = "Some invitations could not be disabled"
      render json: { bulk_results: bulk_results }, status: :unprocessable_entity
    end
  end

  protected

  def bulk_params
    params.require(:bulk).permit(ids: [])
  end

  def set_invitation
    @invitation = Invitation.where id: bulk_params[:ids]
  end
end
