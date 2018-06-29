RSpec.describe ApplicationController do
  describe "#require_login" do
    controller do
      require_login! only: :action_requiring_user

      def action_requiring_user
        render plain: "hia"
      end
    end

    before do
      routes.draw do
        get "action_requiring_user" => "anonymous#action_requiring_user"
      end
    end

    context "with no user" do
      before do
        get :action_requiring_user
      end

      it { is_expected.to redirect_to(root_url) }
    end

    context "with a user" do
      let(:user) { create :user }

      before do
        session[:user_id] = user.id

        get :action_requiring_user
      end

      it { is_expected.not_to redirect_to(root_url) }
      it { expect(response.body).to eq("hia") }
    end
  end
end
