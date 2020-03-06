class RoleConstraint
  def initialize *roles
    @roles = roles
  end

  def matches? request
    user = ::User.find_by_id request.session[:user_id]

    return false unless user.present?

    @roles.any? { |role| user.role? role }
  end
end
