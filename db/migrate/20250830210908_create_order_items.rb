# frozen_string_literal: true

class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.bigint :order_id, null: false
      t.bigint :product_id, null: false
      t.integer :price_cents, null: false

      t.index %i[order_id product_id price_cents], unique: true

      t.timestamps
    end
  end
end
