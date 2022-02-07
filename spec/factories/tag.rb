# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    sequence(:label) { |n| "tag#{ n }" }

    initialize_with { new(label:) }
  end
end
