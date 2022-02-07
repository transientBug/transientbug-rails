# frozen_string_literal: true

class Admin::Invitations::Bulk::DeletesController < AdminController
  before_action :set_invitation

  # DELETE /admin/invitation/bulk/delete
  def destroy
    bulk_results = @invitation.each_with_object({}) do |model, memo|
      memo[model.id] = model.destroy
    end

    all_good = bulk_results.values.all?

    if all_good
      flash[:info] = "Bulk delete of invitations was successful"
      render json: { bulk_results: }, status: :ok
    else
      flash[:error] = "Some invitations could not be deleted"
      render json: { bulk_results: }, status: :unprocessable_entity
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
