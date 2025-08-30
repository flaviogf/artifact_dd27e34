# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:order) }
    it { is_expected.to belong_to(:product) }
  end

  context 'validations' do
    it { is_expected.to validate_numericality_of(:price_cents).only_integer.is_greater_than(0) }
  end
end
