FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "person#{ n }" }
    sequence(:email) { |n| "person#{ n }@example.com" }

    password { "12345" }
    password_confirmation { password }

    trait :with_role do
      transient do
        role_names { [ :default ] }
      end

      after(:create) do |user, evaluator|
        Kernel.warn "DEPRECATION WARNING: the User factory trait :with_role is deprecated and will be removed soon, please use :with_permissions!"

        roles = Array(evaluator.role_names).map do |name|
          create :role, name: name
        end

        user.roles = roles
      end
    end

    trait :with_permissions do
      transient do
        roles_and_permissions { { default: [ 'default.default' ] } }
      end

      after(:create) do |user, evaluator|
        roles = evaluator.roles_and_permissions.to_a.map do |(name, permissions)|
          create(:role, :with_permissions, { name: name, permission_names: permissions })
        end

        user.roles = roles
      end
    end
  end
end
