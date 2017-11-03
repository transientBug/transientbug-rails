require "omniauth"

module OmniAuth
  module Strategies
    autoload :Identity, "omniauth/strategies/identity"
  end

  module Identity
    autoload :Model, "omniauth/identity/model"
  end
end
