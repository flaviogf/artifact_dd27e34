# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Import, type: :model do
  let(:statuses) { %i[pending processing completed failed] }

  describe 'associations' do
    it { is_expected.to have_one_attached(:file) }
  end

  describe 'validations' do
    it { is_expected.to define_enum_for(:status).with_values(statuses).with_default(:pending) }
  end
end
