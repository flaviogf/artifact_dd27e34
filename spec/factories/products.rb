# frozen_string_literal: true

FactoryBot.define do
  factory :product, class: Product do
    price_cents { Faker::Number.number(digits: 5) }
  end
end
