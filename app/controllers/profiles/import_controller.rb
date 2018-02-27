class Profiles::ImportController < ApplicationController
  require_login!

  # GET /profiles/imports
  def index; end

  # POST /profiles/imports
  def create
    @profiles_import = current_user.import_data.create
    @profiles_import.upload.attach params[:upload]

    respond_to do |format|
      format.html { redirect_to profile_import_index_path, notice: "Import was successfully started." }
    end
  end
end
