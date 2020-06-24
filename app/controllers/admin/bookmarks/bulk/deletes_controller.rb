# frozen_string_literal: true

class Admin::Bookmarks::Bulk::DeletesController < AdminController
  before_action :set_bookmarks

  # DELETE /admin/bookmarks/bulk/delete
  def destroy
    bulk_results = @bookmarks.each_with_object({}) do |model, memo|
      memo[model.id] = model.destroy
    end

    all_good = bulk_results.values.all?

    if all_good
      flash[:info] = "Bulk delete of bookmarks was successful"
      render json: { bulk_results: bulk_results }, status: :ok
    else
      flash[:error] = "Some bookmarks could not be deleted"
      render json: { bulk_results: bulk_results }, status: :unprocessable_entity
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
