FactoryBot.define do
  factory :tag do
    sequence(:label) { |n| "tag#{ n }" }

    initialize_with { new(label: label) }
  end
end
