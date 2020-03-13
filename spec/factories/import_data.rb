# frozen_string_literal: true

FactoryBot.define do
  factory :import_datum, class: "ImportData" do
    user { nil }
    import_type { "" }
  end
end
