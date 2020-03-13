# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize user, record
    @user = user
    @record = record
  end

  def index?
    user.present?
  end

  def show?
    record.present?
  end

  def create?
    return false if user.blank?

    return true if user.role? :admin

    user.owner_of? record
  end

  def new?
    create?
  end

  def update?
    return false if user.blank?

    return true if user.role? :admin

    user.owner_of? record
  end

  def edit?
    update?
  end

  def destroy?
    return false if user.blank?

    return true if user.role? :admin

    user.owner_of? record
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize user, scope
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
