class Oauth::Applications::Bulk::DeletesController < ApplicationController
  require_login!

  # DELETE /oauth/applications/bulk/deletes
  def destroy
    # binding.pry
    flash[:info] = "Bulk delete applications successful"
    render json: { heyo: "okayo" }, status: :ok
  end

  protected

  def bulk_params
    params.require(:bulk).permit(ids: [])
  end
end
