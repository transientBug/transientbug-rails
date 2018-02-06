class Bookmarks::Bulk::RecachesController < ApplicationController
  require_login!

  # POST /bookmarks/bulk/recache
  def create
    # all_good = destroy_results.values.all?

    # if all_good
    #   flash[:info] = "Bulk delete applications successful"
    #   render json: { bulk_results: destroy_results }, status: :ok
    # else
    #   flash[:error] = "Some applications could not be deleted"
    #   render json: { bulk_results: destroy_results }, status: :unprocessable_entity
    # end
  end

  protected

  def bulk_params
    params.require(:bulk).permit(ids: [])
  end
end
