require "./lib/form_helpers"

ActionView::Base.default_form_builder.class_eval do
  prepend FormHelpers
end

require "./lib/admin_form_builder"
