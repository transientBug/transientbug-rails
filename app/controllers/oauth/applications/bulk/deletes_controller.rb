# frozen_string_literal: true

class Oauth::Applications::Bulk::DeletesController < ApplicationController
  require_login!
  before_action :set_applications

  # DELETE /oauth/applications/bulk/delete
  def destroy
    # I guess this should be done in a transaction, so that all of the destroys
    # are rolled back if one goes wrong?
    destroy_results = @applications.each_with_object({}) do |application, memo|
      memo[application.id] = application.destroy
    end

    all_good = destroy_results.values.all?

    if all_good
      flash[:info] = "Bulk delete applications successful"
      render json: { bulk_results: destroy_results }, status: :ok
    else
      flash[:error] = "Some applications could not be deleted"
      render json: { bulk_results: destroy_results }, status: :unprocessable_entity
    end
  end

  protected

  def bulk_params
    params.require(:bulk).permit(ids: [])
  end

  def set_applications
    @applications = Doorkeeper::Application.where id: bulk_params[:ids]
  end
end
