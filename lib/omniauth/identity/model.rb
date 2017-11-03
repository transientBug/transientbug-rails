require "active_record"

module OmniAuth
  module Identity
    class Model < ::ActiveRecord::Base
      SCHEMA_ATTRIBUTES = %i(
        name
        email
        nickname
        first_name
        last_name
        location
        description
        image
        phone
      ).freeze

      self.abstract_class = true
      has_secure_password

      class << self
        # Authenticate a user with the given key and password.
        #
        # @param [Hash] conditions The unique login conditions provided for a given identity.
        # @param [String] password The presumed password for the identity.
        # @return [Model] An instance of the identity model class.
        def authenticate conditions, password
          instance = find_by conditions
          return false unless instance
          instance.authenticate password
        end

        # Retrieve the method that will be used to get the user-supplied authentication key
        # @return [Symbol] The method name.
        def auth_key
          @auth_key ||= :email
        end

        def auth_key= key
          @auth_key = key.to_sym
          validates_uniqueness_of key, case_sensitive: false
        end
      end

      # An identifying string that must be globally unique to the
      # application. Defaults to stringifying the `id` method.
      #
      # @return [String] An identifier string unique to this identity.
      def uid
        return nil if self.id.nil?
        self.id.to_s
      end

      # A hash of as much of the standard OmniAuth schema as is stored
      # in this particular model. By default, this will call instance
      # methods for each of the attributes it needs in turn, ignoring
      # any for which `#respond_to?` is `false`.
      #
      # @return [Hash{Symbool => Object}] A symbol-keyed hash of user information.
      def info
        SCHEMA_ATTRIBUTES.each_with_object({}) do |attribute, hash|
          hash[attribute] = send attribute if respond_to? attribute
        end
      end

      # Used to retrieve the user-supplied authentication key (e.g. a
      # username or email). Determined using the class method of the same name,
      # defaults to `:email`
      def auth_key
        send self.class.auth_key
      end
    end
  end
end
