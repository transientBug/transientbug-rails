# frozen_string_literal: true

class Oauth::ApplicationsController < ApplicationController
  layout "page"

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
    @application.owner = current_user

    authorize @application

    if @application.save
      flash[:info] = "Application registered"
      redirect_to oauth_application_url(@application)
    else
      render :new
    end
  end

  def edit; end

  def update
    if @application.update(application_params)
      flash[:info] = "Application updated"
      redirect_to oauth_application_url(@application)
    else
      render :edit
    end
  end

  def destroy
    flash[:info] = "Application deleted" if @application.destroy
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
