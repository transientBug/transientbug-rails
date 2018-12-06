class Oauth::AuthorizedApplications::Bulk::RevokesController < ApplicationController
  require_login!

  # DELETE /oauth/authorized_applications/bulk/revoke
  def destroy
    results = Doorkeeper::AccessToken.authorized_tokens_for(bulk_params[:ids], current_user).each(&:revoke)

    revoke_results = results.each_with_object({}) do |access_token, memo|
      memo[ access_token.application_id ] = access_token.revoked_at
    end

    all_good = revoke_results.values.all?

    if all_good
      flash[:info] = "Bulk revoke of applications successful"
      render json: { bulk_results: revoke_results }, status: :ok
    else
      flash[:error] = "Some applications could not be revoked"
      render json: { bulk_results: revoke_results }, status: :unprocessable_entity
    end
  end

  protected

  def bulk_params
    params.require(:bulk).permit(ids: [])
  end
end
