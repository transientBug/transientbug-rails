module Admin::AdminHelper
  def has_partial? name
    lookup_context.template_exists? "#{ controller_path }/#{ name }", [], true
  end
end
