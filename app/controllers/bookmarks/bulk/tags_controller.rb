class Bookmarks::Bulk::TagsController < ApplicationController
  require_login!
  before_action :set_bookmarks
  before_action :set_tags

  # PUT /bookmarks/bulk/tag
  # PATCH /bookmarks/bulk/tag
  def update
    tags_length = @tags.length

    bulk_results = @bookmarks.each_with_object({}) do |bookmark, memo|
      bookmark.tags = bookmark.tags.to_a.concat(@tags)
      memo[bookmark.id] = bookmark.tags.length >= tags_length
    end

    all_good = bulk_results.values.all?

    if all_good
      flash[:info] = "Bulk tagging of bookmarks was successful"
      render json: { bulk_results: bulk_results }, status: :ok
    else
      flash[:error] = "Some bookmarks could not be tagged"
      render json: { bulk_results: bulk_results }, status: :unprocessable_entity
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
