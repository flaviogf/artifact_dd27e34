# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validations' do
    it { is_expected.to validate_numericality_of(:external_id).only_integer.is_greater_than(0) }

    it { is_expected.to validate_presence_of(:name) }
  end
end
