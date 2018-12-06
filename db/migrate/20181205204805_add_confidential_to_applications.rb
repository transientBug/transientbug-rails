# frozen_string_literal: true
class AddConfidentialToApplications < ActiveRecord::Migration[5.2]
  def change
    # the original migration defaults to true for confidential, however as per
    # https://tools.ietf.org/html/draft-ietf-oauth-native-apps-12
    # the apps that are shared amoung others are not secret or confidential.
    # since this is the default use case for tb's oauth, and to continue having
    # apps function, this was changed to default to false.
    add_column(
      :oauth_applications,
      :confidential,
      :boolean,
      null: false,
      default: false
    )
  end
end
