FactoryBot.define do
  factory :bookmark do
    user
    webpage

    title "test"

    factory :bookmark_with_tags do
      transient do
        tags_count 2
      end

      after(:create) do |bookmark, evaluator|
        bookmark.tags = create_list(:tag, evaluator.tags_count)
      end
    end
  end
end
