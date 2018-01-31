class Oauth::ApplicationsController < ApplicationController
  require_login!
  before_action :set_application, only: [:show, :edit, :update, :destroy]

  def index
    @applications = policy_scope(Doorkeeper::Application).page params[:page]
  end

  def show; end

  def new
    @application = Doorkeeper::Application.new
    authorize @application
  end

  def create
    @application = Doorkeeper::Application.new application_params
    @application.owner = current_user# if Doorkeeper.configuration.confirm_application_owner?

    authorize @application

    if @application.save
      flash[:notice] = I18n.t :notice, scope: [:doorkeeper, :flash, :applications, :create]
      redirect_to oauth_application_url(@application)
    else
      render :new
    end
  end

  def edit; end

  def update
    if @application.update_attributes(application_params)
      flash[:notice] = I18n.t :notice, scope: [:doorkeeper, :flash, :applications, :update]
      redirect_to oauth_application_url(@application)
    else
      render :edit
    end
  end

  def destroy
    flash[:notice] = I18n.t :notice, scope: [:doorkeeper, :flash, :applications, :destroy] if @application.destroy
    redirect_to oauth_applications_url
  end

  private

  def set_application
    @application = current_user.oauth_applications.find params[:id]
    authorize @application
  end

  def application_params
    params.require(:doorkeeper_application).permit(:name, :redirect_uri, :scopes)
  end
end
