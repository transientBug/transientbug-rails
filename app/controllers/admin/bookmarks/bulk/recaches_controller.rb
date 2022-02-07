# frozen_string_literal: true

class Admin::Bookmarks::Bulk::RecachesController < AdminController
  before_action :set_bookmarks

  # POST /admin/bookmarks/bulk/recache
  def create
    bulk_results = @bookmarks.each_with_object({}) do |bookmark, memo|
      memo[bookmark.id] = bookmark.schedule_cache.present?
    end

    all_good = bulk_results.values.all?

    if all_good
      flash[:info] = "Bulk recache of bookmarks successful"
      render json: { bulk_results: }, status: :ok
    else
      flash[:error] = "Some bookmarks could not be recached"
      render json: { bulk_results: }, status: :unprocessable_entity
    end
  end

  protected

  def bulk_params
    params.require(:bulk).permit(ids: [])
  end

  def set_bookmarks
    @bookmarks = Bookmark.where id: bulk_params[:ids]
  end
end
