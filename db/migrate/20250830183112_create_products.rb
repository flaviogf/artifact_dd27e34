# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.bigint :external_id, index: { unique: true }, null: false
      t.integer :price_cents, null: false

      t.timestamps
    end
  end
end
