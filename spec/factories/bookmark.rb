# frozen_string_literal: true

FactoryBot.define do
  factory :bookmark do
    user
    sequence(:uri) { |n| "http://#{ n }.example.com" }

    title { "test" }

    factory :bookmark_with_tags do
      transient do
        tags_count { 2 }
      end

      after(:create) do |bookmark, evaluator|
        bookmark.tags = create_list(:tag, evaluator.tags_count)
      end
    end
  end
end
