# frozen_string_literal: true

FactoryBot.define do
  factory :offline_cache, class: "OfflineCache" do
    bookmark
    document_id { nil }
  end
end
