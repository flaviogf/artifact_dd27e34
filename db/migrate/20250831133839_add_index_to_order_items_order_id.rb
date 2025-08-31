# frozen_string_literal: true

class AddIndexToOrderItemsOrderId < ActiveRecord::Migration[8.0]
  def change
    add_index :order_items, :order_id
  end
end
