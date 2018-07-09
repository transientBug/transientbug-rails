class BookmarksSearcherPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.new.query do |chewy|
        chewy.query term: { user_id: user.id }
      end
    end
  end
end
