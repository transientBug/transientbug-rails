# frozen_string_literal: true

module ApplicationHelper
  def auth_path provider, *args
    [ "auth", provider.to_s, args ].flatten.compact.join "/"
  end

  def template_path_for *args
    template_prefix = "public" unless controller_path.start_with? "admin/"
    template_prefix ||= "admin"

    current_controller = controller_path.gsub(%r{^admin/}, "")

    [
      template_prefix,
      "templates",
      current_controller
    ].concat(args).flatten.compact.join "/"
  end

  def feather_svg name, **opts
    inline_svg_pack_tag "feather/#{ name }.svg", **opts
  end
end
