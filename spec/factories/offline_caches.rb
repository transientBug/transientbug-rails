FactoryBot.define do
  factory :offline_cach, class: "OfflineCache" do
    bookmark { nil }
    document_id { nil }
  end
end
