# frozen_string_literal: true

class Order < ApplicationRecord
  validates :external_id, numericality: { only_integer: true, greater_than: 0 }

  validates :user_external_id, numericality: { only_integer: true, greater_than: 0 }

  validates :date, presence: true
end
