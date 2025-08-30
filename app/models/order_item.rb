# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }
end
