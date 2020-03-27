# frozen_string_literal: true

class AdminFormBuilder < ActionView::Helpers::FormBuilder
  extend Forwardable
  def_delegators :@template, :tag, :content_tag, :capture, :concat, :pluralize

  def all_errors
    return unless object.errors.any?

    tag.div class: "form__errors" do
      concat tag.h2 <<~MSG
        #{ pluralize object.errors.count, 'error' } prohibited this #{ object.class.to_s.humanize } from being saved:
      MSG

      list = tag.ul class: "form__errors-list" do
        object.errors.full_messages.each do |message|
          concat tag.li message, class: "form__errors-item"
        end
      end

      concat list
    end
  end

  def error_group field
    field_class = ["form__field"]

    errors_for field do |has_error, error_messages|
      field_class << "form__field--error" if has_error

      tag.div class: field_class.join(" ") do
        body = capture { yield }
        concat body

        next unless has_error

        concat tag.p error_messages.join(", "), class: "form__field-error"
      end
    end

    nil
  end

  def fieldset title
    fields = capture { yield }

    tag.fieldset class: "form__fieldset" do
      concat tag.legend title, class: "form__legend"
      concat fields
    end
  end

  def actions
    body = capture { yield }

    tag.div class: "form__actions" do
      concat body
    end
  end

  alias_method :orig_submit, :submit

  def submit(*args, **opts)
    add_class opts, "button button--green"

    super
  end

  alias_method :orig_label, :label

  def label(*args, **opts)
    add_class opts, "form__label"

    super
  end

  [:text_field, :password_field, :email_field, :text_area].each do |fun|
    alias_method :"orig_#{ fun }", fun

    define_method fun do |*args, **opts|
      add_class opts, "form__input"

      super(*args, **opts)
      # send :"orig_#{ fun }", *args, **opts
    end
  end

  protected

  def add_class opts, klass
    new_class = opts.fetch :class, ""
    new_class += " #{ klass }"

    opts[:class] = new_class.strip
  end
end
