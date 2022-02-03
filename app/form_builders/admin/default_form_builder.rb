# frozen_string_literal: true

class Admin::DefaultFormBuilder < ActionView::Helpers::FormBuilder
  def section title:, subtitle:, &block
    @template.tag.section(class: "space-y-8 divide-y divide-gray-200 section") do
      @template.tag.div do
        content = @template.tag.div do
          header = @template.tag.h3(title, class: "text-lg leading-6 font-medium text-gray-900")
          header << @template.tag.p(subtitle, class: "mt-1 text-sm text-gray-500")
        end

        content << @template.capture(&block)
      end
    end
  end

  def label method, text=nil, opts={}, &block
    default_opts = { class: "block text-sm font-medium text-gray-700" }
    merged_opts = default_opts.merge(opts)

    super(method, text, merged_opts, &block)
  end

  [
    :text_field,
    :text_area,
    :color_field,
    :date_field,
    :datetime_field,
    :datetime_local_field,
    :email_field,
    :month_field,
    :number_field,
    :password_field,
    :phone_field,
    :range_field,
    :search_field,
    :telephone_field,
    :time_field,
    :url_field,
    :week_field
  ].each do |wrapped_method|
    class_eval do
      define_method(wrapped_method) do |method, opts={}|
        text_field_wrapper method, opts do |inner_method, inner_opts|
          super(inner_method, inner_opts)
        end
      end
    end
  end

  def color_field method, opts={}
    color_field_wrapper method, opts do |inner_method, inner_opts|
      super(inner_method, inner_opts)
    end
  end

  # def checkbox method, opts={}, checked_value="1", unchecked_value="0"
  # end

  private

  def color_field_wrapper method, opts={}
    field_errors = @object.errors.messages_for method

    label_opts = {}.merge(opts.fetch(:label_opts, {}))
    input_opts = { class: "color-input #{ if field_errors.any?
                                            'border-2 border-red-500'
                                          end }" }.merge(opts.fetch(:input_opts,
                                                                    {}))

    help_text = opts.fetch(:help_text, "")

    content = label(method, label_opts)

    content << @template.tag.div(class: "mt-1") do
      @template.capture { yield(method, input_opts) }
    end

    content << @template.tag.p(field_errors.join(", "), class: "mt-1 text-sm text-red-600") if field_errors.any?
    content << @template.tag.p(help_text, class: "mt-1 text-sm text-gray-500") if help_text
  end

  def text_field_wrapper method, opts={}
    field_errors = @object.errors.messages_for method

    label_opts = {}.merge(opts.fetch(:label_opts, {}))
    input_opts = { class: "input w-full #{ 'border-2 border-red-500' if field_errors.any? }" }.merge(opts.fetch(
                                                                                                       :input_opts, {}
                                                                                                     ))

    help_text = opts.fetch(:help_text, "")

    content = label(method, label_opts)

    content << @template.tag.div(class: "mt-1") do
      @template.capture { yield(method, input_opts) }
    end

    content << @template.tag.p(field_errors.join(", "), class: "mt-1 text-sm text-red-600") if field_errors.any?
    content << @template.tag.p(help_text, class: "mt-1 text-sm text-gray-500") if help_text
  end
end
