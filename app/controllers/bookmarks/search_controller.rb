# frozen_string_literal: true

class Bookmarks::SearchController < ApplicationController
  require_login!

  def index
    @bookmarks = policy_scope(Bookmark).search(params[:q]).includes(:tags).page params[:page]
  end
end
