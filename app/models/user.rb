# frozen_string_literal: true

class User < ApplicationRecord
  validates :external_id, numericality: { only_integer: true, greater_than: 0 }

  validates :name, presence: true
end
