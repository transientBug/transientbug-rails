module ApplicationHelper
  def auth_path provider, *args
    [ "auth", provider.to_s, args ].flatten.compact.join "/"
  end

  def render_service_announcements
    render partial: "layouts/service_announcements", locals: { service_announcements: ServiceAnnouncements.displayable }
  end
end
