# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "person#{ n }" }
    sequence(:email) { |n| "person#{ n }@example.com" }

    password { "12345" }
    password_confirmation { password }

    trait :with_permissions do
      transient do
        permissions { [ "default.default" ] }
      end

      after(:create) do |user, evaluator|
        role = create(:role, :with_permissions, name: "test.default", permission_keys: evaluator.permissions)

        user.roles << role
      end
    end
  end
end
