# frozen_string_literal: true

class PermissionConstraint
  def initialize *permissions
    @permissions = permissions
  end

  def matches? request
    user = ::User.includes(:roles).find_by(id: request.session[:user_id])

    return false if user.blank?

    @permissions.any? { |permission| user.permission? permission }
  end
end
