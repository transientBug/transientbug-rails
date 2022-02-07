# frozen_string_literal: true

class Api::V1::Bookmarks::CheckController < Api::V1Controller
  # GET /api/v1/bookmarks/check
  def index
    return head :bad_request unless params[:uri]
    return head :not_found unless bookmark_found?

    head :found
  end

  protected

  def bookmark_found?()= current_user.bookmarks.where(uri: params[:uri]).any?
end
