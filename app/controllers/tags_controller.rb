# frozen_string_literal: true

class TagsController < ApplicationController
  before_action :set_tag, only: [ :show ]

  # GET /tags
  def index; end

  # GET /tags/1
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
