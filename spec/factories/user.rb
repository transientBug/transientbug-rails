FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "person#{ n }" }
    sequence(:email) { |n| "person#{ n }@example.com" }

    password "12345"
    password_confirmation { password }

    trait :with_role do
      transient do
        role_names [ :default ]
      end

      after(:create) do |user, evaluator|
        roles = Array(evaluator.role_names).map do |name|
          create :role, name: name
        end

        user.roles = roles
      end
    end
  end
end
