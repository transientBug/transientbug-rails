# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role#{ n }" }

    trait :with_permissions do
      transient do
        permission_keys { [ "default.default" ] }
      end

      after(:create) do |role, evaluator|
        role.permission_keys = evaluator.permission_keys
      end
    end
  end
end
