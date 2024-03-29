# frozen_string_literal: true

class Api::V1::BookmarksController < Api::V1Controller
  before_action :set_bookmark, only: [:show, :update, :destroy]

  # GET /api/v1/bookmarks
  def index
    @bookmarks = policy_scope(current_user.bookmarks).page params[:page]
  end

  # GET /api/v1/bookmarks/1
  def show; end

  # POST /api/v1/bookmarks
  def create
    params = bookmark_params.to_h.compact
    @bookmark = Bookmark.for(current_user, params["uri"])

    authorize @bookmark

    if @bookmark.id
      render :show, status: :ok, location: @bookmark
      return
    end

    @bookmark.assign_attributes params
    @bookmark.tags = @bookmark.tags.to_a.concat(tags_models)

    if @bookmark.upsert
      render :show, status: :created, location: @bookmark
    else
      # TODO: these errors might not map directly 1-1 with the API surface
      # (referencing webpage_id for example) and should be mapped
      render json: @bookmark.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/bookmarks/1
  def update
    @bookmark.assign_attributes bookmark_params
    @bookmark.tags = tags_models

    if @bookmark.save
      render :show, status: :ok, location: @bookmark
    else
      render json: @bookmark.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/bookmarks/1
  def destroy
    @bookmark.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bookmark
    @bookmark = current_user.bookmarks.find(params[:id])
    authorize @bookmark
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def bookmark_params
    params.require(:data).require(:attributes).permit(:title, :description, :uri)
  end

  def tags_params
    params.require(:data).require(:attributes).permit(tags: [])
  end

  def tags_models
    Tag.find_or_create_tags tags: tags_params[:tags].to_a.uniq
  end
end
