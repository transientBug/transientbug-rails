class Oauth::AuthorizedApplications::Bulk::RevokesController < ApplicationController
  require_login!

  # POST /oauth/authorized_applications/bulk/revokes
  def create
    # binding.pry
    flash[:info] = "Bulk application revoke successful"
    render json: { heyo: "okayo" }, status: :ok
  end

  protected

  def bulk_params
    params.require(:bulk).permit(ids: [])
  end
end
