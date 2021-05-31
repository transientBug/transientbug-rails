# frozen_string_literal: true

class Admin::ServiceAnnouncementsController < AdminController
  before_action :set_service_announcement, only: [:show, :edit, :update, :destroy]
  # default_form_builder Admin::DefaultFormBuilder

  module Filters
    def self.filter_on_name query, value, filters
      table = ServiceAnnouncement.arel_table
      query.where(table[:title].matches("%#{ value }%"))
    end

    def self.filter_on_status query, value, filters
      return query if value.blank?

      table = ServiceAnnouncement.arel_table
      now = Time.now

      q = table[:start_at].gteq(now).or(table[:start_at].eq(nil))
        .and(table[:end_at].lteq(now).or(table[:end_at].eq(nil)))
        .and(table[:active].not_eq(false))

      if value == "active"
        query.where(q)
      else
        query.where.not(q)
      end
    end
  end

  private def filters() = params.permit(filter: {})[:filter].to_h

  private def filter_methods
    @filter_methods ||= Filters.methods.map { [_1.match(%r{^filter_on_(.*)$})&.captures&.first, _1] }.filter { _1[0] }
  end

  private def with_filters base_query
    filter_methods.reduce(base_query) do |query, (key, method)|
      next query unless filters[key]

      Filters.send(method, query, filters[key], filters)
    end
  end

  # GET /service_announcements
  def index
    @service_announcements = with_filters(ServiceAnnouncement.all).order(created_at: :desc).page params[:page]
  end

  # GET /service_announcements/1
  def show; end

  # GET /service_announcements/new
  def new
    @service_announcement = ServiceAnnouncement.new
  end

  # POST /service_announcements
  def create
    @service_announcement = ServiceAnnouncement.new service_announcement_params

    respond_to do |format|
      if @service_announcement.save
        format.html do
          redirect_to [:admin, @service_announcement],
                      notice: "Service Announcement was successfully created."
        end
      else
        format.html { render :new }
      end
    end
  end

  # GET /service_announcements/1/edit
  def edit; end

  # PATCH/PUT /service_announcements/1
  def update
    respond_to do |format|
      if @service_announcement.update(service_announcement_params)
        format.html do
          redirect_back fallback_location: [:admin, @service_announcement],
                        notice: "Service Announcement was successfully updated."
        end
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /service_announcements/1
  def destroy
    respond_to do |format|
      if @service_announcement.destroy
        format.html do
          redirect_to admin_service_announcements_url,
                      notice: "Service Announcement was successfully deleted."
        end
      else
        format.html { render :new }
      end
    end
  end

  private

  def set_service_announcement
    @service_announcement = ServiceAnnouncement.find params[:id]
  end

  def service_announcement_params
    params.require(:service_announcement).permit(
      :title,
      :message,
      :color,
      :icon,
      :start_at,
      :end_at,
      :active,
      :logged_in_only
    )
  end
end
