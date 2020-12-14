# frozen_string_literal: true

module Admin::BookmarksHelper
  def error_count_label error_messages
    error_count = error_messages.count

    icon = "smile"
    color = "green"

    if error_count > 0
      icon = "warning circle"
      color = "red"
    end

    tag.div(class: "ui label #{ color }") do
      capture do
        concat tag.i("", class: "icon #{ icon }")
        concat "#{ error_count } Error".pluralize(error_count)
      end
    end
  end
end
