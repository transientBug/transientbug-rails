# frozen_string_literal: true

FactoryBot.define do
  factory :error_message do
    key { "MyString" }
    message { "MyText" }
  end
end
