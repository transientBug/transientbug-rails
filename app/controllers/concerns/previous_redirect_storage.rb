# Nearly 100% copy pasta from device
# https://github.com/plataformatec/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
module PreviousRedirectStorage
  extend ActiveSupport::Concern

  protected

  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent).
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  # - The request is the session controller as that could cause an infinite redirect loop.
  def storable_location?
    request.get? && !request.xhr? && !is_a?(SessionsController)
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def store_location_for resource_or_scope, location
    session_key = stored_location_key_for resource_or_scope
    session[session_key] = location
  end

  def stored_location_for resource_or_scope
    session_key = stored_location_key_for resource_or_scope

    return session.delete(session_key) if is_navigational_format?

    session[session_key]
  end

  def is_navigational_format?
    format = request.format&.ref
    ["*/*", :html].include? format
  end

  def after_sign_in_path_for resource_or_scope
    stored_location_for resource_or_scope
  end

  def stored_location_key_for resource_or_scope
    "#{ resource_or_scope }_return_to"
  end
end