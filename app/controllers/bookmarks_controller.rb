# frozen_string_literal: true

class BookmarksController < ApplicationController
  require_login!
  before_action :set_bookmark, only: [ :show, :edit, :update, :destroy ]

  # GET /bookmarks
  # GET /bookmarks.json
  def index
    @bookmarks = policy_scope(Bookmark)
      .includes(:tags, offline_caches: [:error_messages])
      .page params[:page]
  end

  # GET /bookmarks/new
  def new
    @bookmark = current_user.bookmarks.new

    authorize @bookmark
  end

  # POST /bookmarks
  # POST /bookmarks.json
  def create
    @bookmark = current_user.bookmarks.new(bookmark_params)

    authorize @bookmark

    respond_to do |format|
      if @bookmark.save
        format.html { redirect_to @bookmark, notice: "Bookmark was successfully created." }
        format.json { render :show, status: :created, location: @bookmark }
      else
        format.html { render :new }
        format.json { render json: @bookmark.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /bookmarks/1
  # GET /bookmarks/1.json
  def show
    respond_to do |format|
      format.html { render :show }
      format.json { render :show, status: :ok }
    end
  end

  # GET /bookmarks/1/edit
  def edit; end

  # PATCH/PUT /bookmarks/1
  # PATCH/PUT /bookmarks/1.json
  def update
    respond_to do |format|
      if @bookmark.update(bookmark_params)
        format.html { redirect_to @bookmark, notice: "Bookmark was successfully updated." }
        format.json { render :show, status: :ok, location: @bookmark }
      else
        format.html { render :edit }
        format.json { render json: @bookmark.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookmarks/1
  # DELETE /bookmarks/1.json
  def destroy
    respond_to do |format|
      if @bookmark.destroy
        format.html { redirect_to bookmarks_url, notice: "Bookmark was successfully deleted." }
        format.json { head :no_content }
      else
        format.html { render :new }
        format.json { render json: @bookmark.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_bookmark
    @bookmark = current_user.bookmarks.includes(
      :tags,
      offline_caches: [
        :error_messages
      ]
    ).find(params[:id])

    authorize @bookmark
  end

  def bookmark_params
    permitted_attributes(@bookmark || Bookmark).tap do |obj|
      tag_input = params[:bookmark].fetch(:tags, [])
      tag_input = tag_input.split(",") if tag_input.is_a? String

      tags = Tag.find_or_create_tags tags: tag_input

      obj.merge!(tags:)
    end
  end
end
