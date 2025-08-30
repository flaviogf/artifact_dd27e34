# frozen_string_literal: true

class Product < ApplicationRecord
  validates :external_id, numericality: { only_integer: true, greater_than: 0 }

  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }
end
