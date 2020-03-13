# frozen_string_literal: true

require "rails_helper"

RSpec.describe CspViolationReportController, type: :controller do
  let(:valid_attributes) do
    {
      "csp-violation": {}
    }
  end

  let(:valid_session) do
    {}
  end

  before do
    post :create, body: JSON.dump(valid_attributes), session: valid_session
  end

  it { expect(response).to be_successful }
end
