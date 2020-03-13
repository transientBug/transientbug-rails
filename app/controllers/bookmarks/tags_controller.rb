class Bookmarks::TagsController < ApplicationController
  before_action :set_tag, only: [ :show ]

  # GET /bookmarks/tags
  def index; end

  # GET /bookmarks/tags/thing
  def show
    @bookmarks = policy_scope(Bookmark)
      .joins(:bookmarks_tags)
      .where(bookmarks_tags: { tag_id: @tag })
      .page params[:page]
  end

  private

  def set_tag
    @tag = Tag.find params[:id]
  end
end
