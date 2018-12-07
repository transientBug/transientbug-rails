module Admin::AdminHelper
  def partial_for? name
    lookup_context.template_exists? "#{ controller_path }/#{ name }", [], true
  end
end
