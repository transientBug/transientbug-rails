FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "person#{n}" }
    sequence(:email) { |n| "person#{n}@example.com" }

    password "12345"
    password_confirmation { password }
  end
end
