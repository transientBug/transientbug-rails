FactoryBot.define do
  factory :webpage do
    sequence(:uri_string) { |n| "http://#{ n }.example.com" }
  end
end
