# frozen_string_literal: true

FactoryBot.define do
  factory :order_item, class: OrderItem do
    product { create(:product) }
    price_cents { Faker::Number.number(digits: 5) }
  end
end
