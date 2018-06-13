class BookmarkSearcherPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.new.query(term: { user_id: user.id })
    end
  end
end
