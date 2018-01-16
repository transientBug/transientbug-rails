class BookmarkPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # return scope.where(public: true) unless user.present?

      return scope.all if user.role? :admin

      scope.where(user: user).order(:created_at)
    end
  end

  def show?
    return false unless user.present?
    # return record.public? unless user.present?

    return true if user.role? :admin

    # return record.public? unless user.owner_of? record

    true
  end

  def permitted_attributes
    [ :title, :description ]
  end
end
