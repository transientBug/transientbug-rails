# frozen_string_literal: true

module Admin::AdminHelper
  def partial_for? name
    lookup_context.template_exists? "#{ controller_path }/#{ name }", [], true
  end

  def default_form_with(model: nil, scope: nil, url: nil, format: nil, **options)
    defaults = { builder: Admin::DefaultFormBuilder, html: { class: "generic-form" } }.merge(options)

    form_with model: model, scope: scope, url: url, format: format, **defaults do |f|
      tag.div(class: "form-wrapper") do
        capture { yield f }
      end
    end
  end
end
