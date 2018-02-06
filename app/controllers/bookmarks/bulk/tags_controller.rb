class Bookmarks::Bulk::TagsController < ApplicationController
  require_login!
  before_action :set_bookmarks

  # PUT /bookmarks/bulk/tag
  # PATCH /bookmarks/bulk/tag
  def update
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

  def set_bookmarks
    @bookmarks = Bookmark.where id: bulk_params[:ids]
  end
end
