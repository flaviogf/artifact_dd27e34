# frozen_string_literal: true

class Import < ApplicationRecord
  has_one_attached :file

  enum :status, %i[pending processing completed failed], default: :pending
end
