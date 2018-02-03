class Oauth::Applications::Bulk::DeletesController < ApplicationController
  require_login!

  # POST /oauth/applications/bulk/deletes
  def create
    # binding.pry
    flash[:info] = "Bulk delete applications successful"
    render json: { heyo: "okayo" }, status: :ok
  end

  protected

  def bulk_params
    params.require(:bulk).permit(ids: [])
  end
end
