# frozen_string_literal: true

class AddIndexToOrdersOnIdAndDate < ActiveRecord::Migration[8.0]
  def change
    add_index :orders, %i[id date]
  end
end
