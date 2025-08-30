# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  context 'validations' do
    it { is_expected.to validate_numericality_of(:price_cents).only_integer.is_greater_than(0) }
  end
end
