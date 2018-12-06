module ApplicationHelper
  def auth_path provider, *args
    [ "auth", provider.to_s, args ].flatten.compact.join "/"
  end

  def render_service_announcements
    service_announcements = ServiceAnnouncement.displayable
    service_announcements = service_announcements.where(logged_in_only: false) unless current_user

    render partial: "layouts/service_announcements", locals: { service_announcements: service_announcements }
  end

  # Builds out a "clickable item" div which contains all of the information
  # needed for bulk actions, including which modal template to use, and the bulk
  # action to be completed. This tag is hidden by default and JS unhides it
  # after one or more bulk select checkboxes is checked.
  #
  # Content passed in through the block ends up inside of the div, useful for
  # icons and text about the action.
  # rubocop:disable Metrics/AbcSize
  def bulk_edit_action behavior, **opts, &block
    template = opts.delete(:template) { template_path_for(behavior) }

    data = {
      group: "bulk-edit-action",
      behavior: behavior,
      template: template
    }.merge opts.except(:id, :class)

    options = {
      data: JSON.parse(data.to_json),
      class: "hidden clickable item"
    }.merge opts.slice(:id, :class)

    tag.div(**options, &block)
  end
  # rubocop:enable Metrics/AbcSize

  # Renders a checkbox that, when clicked, will check all of the bulk select
  # checkboxes on the page through some JS magic
  def select_all_checkbox
    tag.div(class: "ui checkbox") do
      capture do
        concat check_box_tag("select-all", nil, false, data: { behavior: "select-all" })
        concat tag.label "" unless block_given?
        yield if block_given?
      end
    end
  end

  # A bulk select checkbox, used to find which rows are effected by the bulk
  # action being performed.
  def bulk_edit_checkbox model
    tag_id = sanitize_to_id("select-#{ model.class.to_s.underscore }-data-#{ model.id }")

    tag.div(class: "ui checkbox") do
      capture do
        concat check_box_tag(tag_id, nil, false, data: { behavior: "select" })
        concat tag.label "" unless block_given?
        yield if block_given?
      end
    end
  end

  # Renders a div that contains an inner div with the models attributes as data
  # attributes on the tag, and a bulk select checkbox. Finding all the checked
  # bulk select checkboxes and grabbing their sibilings will provide you with
  # the data for every selected row. Use only to include/exclude
  # which fields in the attributes should make it to the html.
  # rubocop:disable Metrics/AbcSize
  def model_tag model, **opts, &block
    attributes = Array(opts.delete(:only)).map(&:to_sym)
    attributes ||= model.attribute_names.map(&:to_sym)

    # force the ID to be present because reasons
    attributes << :id
    attributes.uniq!

    attribute_values = attributes.each_with_object({}) do |attribute, memo|
      memo[ attribute ] = model.send(attribute).to_s
    end

    no_checkbox = opts.delete(:no_checkbox)

    # This seems silly but it turns everything into nicely formatted data,
    # rather than trying to put a Time object into HTML
    data = JSON.parse(attribute_values.to_json)

    options = {
      class: "hidden model-data",
      id: sanitize_to_id("#{ model.class.to_s.underscore }-data-#{ model.id }"),
      data: data
    }.merge opts

    display = "display: inline"
    display = "display: none" if no_checkbox

    # Ensures that when we grab the siblings of the checkboxes that are
    # checked, that we'll end up with the correct div containing all the datas
    tag.div style: display do
      capture do
        concat tag.div(**options, &block)
        concat bulk_edit_checkbox model unless no_checkbox
      end
    end
  end

  # Renders a "clickable item" that contains all the information needed to
  # trigger and display a modal including which template for the modal, and
  # what data should be available inside of the template. The JS uses the data
  # from the matching #model_tag to help give more context for the template.
  def modal_tag model, template=nil, **opts, &block
    template = opts.delete(:template) { template_path_for(template) }

    data = {
      behavior: "neomodal",
      template: template,
      storage: sanitize_to_id("#{ model.class.to_s.underscore }-data-#{ model.id }")
    }.merge opts.except(:id, :class)

    options = {
      data: JSON.parse(data.to_json),
      class: "clickable ui item"
    }.merge opts.slice(:id, :class)

    tag.a(**options, &block)
  end
  # rubocop:enable Metrics/AbcSize

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

  # Copy and pasted from Rails's actionview/lib/action_view/helpers/form_tag_helper.rb
  # since the form builders do this but the method is private and
  # not-opt-outable which is causing issues with tag ids that have slashes in
  # them, getting sanitized in checkboxes
  def sanitize_to_id name
    name.to_s.delete("]").tr("^-a-zA-Z0-9:.", "_")
  end
end
