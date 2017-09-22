module ApplicationHelper
  def login_path provider
    "/auth/#{ provider.to_s }"
  end
end
