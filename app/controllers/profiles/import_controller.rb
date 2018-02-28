class Profiles::ImportController < ApplicationController
  require_login!

  # GET /profiles/imports
  def index
    @import_data = current_user.import_data.new
  end

  # POST /profiles/imports
  def create
    @profiles_import = current_user.import_data.create
    @profiles_import.upload.attach params[:import_data][:upload]

    respond_to do |format|
      format.html { redirect_to profile_import_index_path, notice: "Import was successfully started." }
    end
  end
end
