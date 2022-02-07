# frozen_string_literal: true

class ServiceAnnouncementBannerComponent < ViewComponent::Base
  extend Forwardable

  def_delegators :@service_announcement, :title

  with_collection_parameter :service_announcement

  def initialize service_announcement:
    @service_announcement = service_announcement
  end

  def color()= @service_announcement.color_text
  def icon()= @service_announcement.icon_text || "radio"
end
