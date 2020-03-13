# frozen_string_literal: true

FactoryBot.define do
  factory :permission do
    key { "MyString" }
    sequence(:name) { |n| "role#{ n }" }
    description { "MyString" }
  end
end
