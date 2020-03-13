# frozen_string_literal: true

class RoleConstraint
  def initialize *roles
    @roles = roles
  end

  def matches? request
    user = ::User.find_by id: request.session[:user_id]

    return false if user.blank?

    @roles.any? { |role| user.role? role }
  end
end
