FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role#{ n }" }

    trait :with_permissions do
      transient do
        permission_names { [ "default.default" ] }
      end

      after(:create) do |role, evaluator|
        permissions = Array(evaluator.permission_names).map do |name|
          create :permission, name: name, key: name
        end

        role.permissions = permissions
      end
    end
  end
end
