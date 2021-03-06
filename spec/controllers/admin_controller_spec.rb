# frozen_string_literal: true

RSpec.describe AdminController do
  controller do
    def action_requiring_admin
      render plain: "hia"
    end
  end

  before do
    skip "removed the require_admin since things are hidden behind a constraint"

    routes.draw do
      get "action_requiring_admin" => "admin#action_requiring_admin"
    end

    controller.append_view_path "spec/views"
  end

  describe "#require_admin" do
    render_views

    context "with no user" do
      before do
        get :action_requiring_admin
      end

      it { expect(response).to have_http_status(:not_found) }
    end

    context "with a non-admin user" do
      let(:user) { create :user }

      before do
        session[:user_id] = user.id

        get :action_requiring_admin
      end

      it { expect(response).to have_http_status(:not_found) }
    end

    context "with an admin user" do
      let(:user) { create :user, :with_permissions, permissions: ["admin.access"] }

      before do
        session[:user_id] = user.id

        get :action_requiring_admin
      end

      it { is_expected.not_to redirect_to(login_url) }
      it { is_expected.not_to have_http_status(:not_found) }
      it { expect(response.body).to eq("hia") }
    end
  end
end
