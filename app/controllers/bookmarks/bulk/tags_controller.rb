class Bookmarks::Bulk::TagsController < ApplicationController
  require_login!
  before_action :set_bookmarks
  before_action :set_tags

  # PUT /bookmarks/bulk/tag
  # PATCH /bookmarks/bulk/tag
  def update
    bulk_result = @bookmarks.map do |bookmark|
      bookmark.tags = bookmark.tags.to_a.concat(@tags)
    end

    all_good = bulk_result.values.all?

    if all_good
      flash[:info] = "Bulk delete applications successful"
      render json: { bulk_results: bulk_result }, status: :ok
    else
      flash[:error] = "Some applications could not be deleted"
      render json: { bulk_results: bulk_result }, status: :unprocessable_entity
    end
  end

  protected

  def bulk_params
    params.require(:bulk).permit(ids: [], tags: [])
  end

  def set_bookmarks
    @bookmarks = Bookmark.where id: bulk_params[:ids]
  end

  def set_tags
    @tags = Tag.find_or_create_tags tags: bulk_params[:tags].to_a
  end
end
