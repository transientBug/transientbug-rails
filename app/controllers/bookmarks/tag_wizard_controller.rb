class Bookmarks::TagWizardController < ApplicationController
  require_login!
  before_action :set_bookmark, only: [:update]

  def index
    scope = lambda do
      includes(
        :webpage,
        :tags,
        :user,
        :offline_caches
      )
    end

    @bookmark = BookmarksSearcher.new.search("NOT has:tags")
      .query(term: { user_id: current_user.id })
      .per(1)
      .load(scope: scope)
      .objects.first

    return render "no_untagged" unless @bookmark

    authorize @bookmark
  end

  def update
    if bookmark_params[:tags].any? && @bookmark.update(bookmark_params)
      redirect_to bookmarks_tag_wizard_index_path, notice: "Bookmark tagged!"
    else
      flash.alert = "You've got to add at least one tag to the bookmark!"
      redirect_to bookmarks_tag_wizard_index_path
    end
  end

  private

  def set_bookmark
    @bookmark = current_user.bookmarks.find params[:id]

    authorize @bookmark
  end

  def bookmark_params
    params.require(:bookmark).permit(:tags).tap do |obj|
      tag_input = params.dig(:bookmark).fetch(:tags, [])
      tag_input = tag_input.split(",") if tag_input.is_a? String

      tags = Tag.find_or_create_tags tags: tag_input

      obj.merge!(tags: tags)
    end
  end
end
