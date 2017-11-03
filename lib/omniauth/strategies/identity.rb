module OmniAuth
  module Strategies
    # The identity strategy allows you to provide simple internal
    # user authentication using the same process flow that you
    # use for external OmniAuth providers.
    class Identity
      include ::OmniAuth::Strategy

      option :fields, [:email]
      option :on_login, nil
      option :on_registration, nil
      option :on_failed_registration, nil
      option :locate_conditions, ->(req) { { model.auth_key => req["auth_key"] } }

      def request_phase
        return options[:on_login].call self.env if options[:on_login]

        OmniAuth::Form.build(
          title: options.fetch(:title, "Identity Verification"),
          url: callback_path
        ) do |f|
          f.text_field "Login", "auth_key"
          f.password_field "Password", "password"
          # f.html <<~HTML
          #   <p align="center">
          #     <a href="#{ registration_path }">Create an Identity</a>
          #   </p>
          # HTML
        end.to_response
      end

      def callback_phase
        fail! :invalid_credentials unless identity
        super
      end

      uid { identity.uid }
      info { identity.info }

      def other_phase
        call_app!
        # return call_app! unless on_registration_path?
        # return registration_form if request.get?
        # registration_phase if request.post?
      end

      # def registration_path
      #   options.fetch :registration_path, "#{ path_prefix }/#{ name }/register"
      # end

      # def on_registration_path?
      #   on_path? registration_path
      # end

      # def registration_form
      #   return options[:on_registration].call self.env if options[:on_registration]

      #   OmniAuth::Form.build(title: "Register Identity") do |f|
      #     options[:fields].each do |field|
      #       f.text_field field.to_s.capitalize, field.to_s
      #     end

      #     f.password_field "Password", "password"
      #     f.password_field "Confirm Password", "password_confirmation"
      #   end.to_response
      # end

      # def registration_phase
      #   attribute_keys = options[:fields] + [:password, :password_confirmation]

      #   attributes = attribute_keys.each_with_object({}) { |key, memo| memo[key] = request[key.to_s] }
      #   @identity = model.create attributes

      #   if @identity.persisted?
      #     env["PATH_INFO"] = callback_path
      #     return callback_phase
      #   end

      #   return registration_form unless options[:on_failed_registration]

      #   self.env["omniauth.identity"] = @identity
      #   options[:on_failed_registration].call self.env
      # end

      protected

      def identity
        if options.locate_conditions.is_a? Proc
          conditions = instance_exec(request, &options.locate_conditions)
        else
          conditions = options.locate_conditions
        end

        conditions = conditions.to_h

        @identity ||= model.authenticate conditions, request["password"]
      end

      def model
        options.fetch :model, ::Identity
      end
    end
  end
end
