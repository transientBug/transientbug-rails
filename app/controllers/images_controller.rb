class ImagesController < ApplicationController
  require_login! only: [ :new, :edit, :create, :update, :destroy ]
  before_action :set_image, only: [ :show, :edit, :update, :destroy ]

  # GET /images
  # GET /images.json
  def index
    @images = policy_scope(Image).with_attached_image
  end

  # GET /images/1
  # GET /images/1.json
  def show
  end

  def search
    @images = ImagesIndex.type_hash["image"]
      .query(
        bool: {
          should: [
            { term: { title: params[:q] } },
            { term: { tags: params[:q] } }
          ]
        }
      ).objects
  end

  # GET /images/new
  def new
    @image = current_user.images.new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  # POST /images.json
  def create
    @image = current_user.images.new(image_params)
    image = params.dig(:image, :image)

    respond_to do |format|
      if @image.save && image
        @image.image.attach image if image
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
    image = params.dig(:image, :image)

    respond_to do |format|
      if @image.update(image_params)
        @image.image.attach image if image
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
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url, notice: "Image was successfully destroyed." }
      format.json { head :no_content }
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
end
