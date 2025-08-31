# frozen_string_literal: true

FactoryBot.define do
  factory :order, class: Order do
    user { create(:user) }
    date { Faker::Date.backward(days: 30) }
  end
end
