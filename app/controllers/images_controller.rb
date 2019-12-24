class ImagesController < ApplicationController
  layout "page"

  require_login! only: [ :new, :edit, :create, :update, :destroy ]
  before_action :set_image, only: [ :show, :edit, :update, :destroy ]

  # GET /images
  # GET /images.json
  def index
    @images = policy_scope(Image).with_attached_image.page params[:page]
  end

  # GET /images/tag/thing
  # GET /images/tag/thing.json
  def tag
    @images = policy_scope(Image).with_attached_image.where("? = ANY(tags)", params[:tag]).page params[:page]
  end

  # GET /images/1
  # GET /images/1.json
  def show
    respond_to do |format|
      format.html { render :show }
      format.json { render :show, status: :ok }
      format.gif do
        type = @image.image.blob.content_type || "image/gif"

        @image.image.blob.open do |file|
          send_data file, type: type, disposition: "inline"
        end
      end
    end
  end

  # GET /images/tags/autocomplete.json
  def autocomplete
    @tags = tags_search.take(params.fetch(:c, 5))
      .tap { |arr| arr.unshift params[:q] }
      .uniq

    respond_to do |format|
      format.json { render :autocomplete, status: :ok }
    end
  end

  # GET /images/search
  # GET /images/search.json
  def search
    @images = ImagesIndex::Image.query(
      bool: {
        should: [
          { match: { title: params[:q] } },
          { match: { tags: params[:q] } }
        ]
      }
    ).objects.page params[:page]
    @tags = tags_search

    respond_to do |format|
      format.html { render :search }
      format.json { render :search, status: :ok }
    end
  end

  # GET /images/new
  def new
    @image = current_user.images.new
  end

  # GET /images/1/edit
  def edit; end

  # POST /images
  # POST /images.json
  def create
    image_param = params.dig(:image, :image)
    tags = params.dig(:image, :tags).split(",").reject(&:empty?).map(&:strip)

    @image = current_user.images.new(image_params.merge(tags: tags))

    respond_to do |format|
      if @image.save && image_param
        @image.image.attach image_param
        format.html { redirect_to @image, notice: "Image was successfully created." }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    image_param = params.dig(:image, :image)
    tags = params.dig(:image, :tags).split(",").reject(&:empty?).map(&:strip)

    respond_to do |format|
      if @image.update(image_params.merge(tags: tags))
        @image.image.attach image_param if image_param
        format.html { redirect_to @image, notice: "Image was successfully updated." }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.update disabled: true

    respond_to do |format|
      if @image.save
        format.html { redirect_to images_url, notice: "Image was successfully disabled." }
        format.json { head :no_content }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = policy_scope(Image).with_attached_image.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def image_params
    permitted_attributes(@image || Image)
  end

  def images_search
    res = ImagesIndex.suggest(
      "image-suggest" => {
        text: params[:q],
        completion: {
          field: :suggest,
          fuzzy: {
            fuzziness: 2
          },
          contexts: {
            type: [ :image ]
          }
        }
      }
    )
      .suggest["image-suggest"]

    ids ||= []
    ids += res.first["options"].map { |row| row.dig("_id") } if res.present?

    Image.where id: ids
  end

  def tags_search
    res = ImagesIndex.suggest(
      "tag-suggest" => {
        text: params[:q],
        completion: {
          field: :suggest,
          fuzzy: {
            fuzziness: 2
          },
          contexts: {
            type: [ :tag ]
          }
        }
      }
    )
      .suggest["tag-suggest"]

    tags ||= []
    tags += res.first["options"].map { |row| row.dig("_source", "tag") } if res.present?

    tags
  end
end
