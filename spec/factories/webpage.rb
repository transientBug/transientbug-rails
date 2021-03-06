# frozen_string_literal: true

FactoryBot.define do
  factory :webpage do
    sequence(:uri) { |n| Addressable::URI.parse("http://#{ n }.example.com") }
  end
end
