# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.bigint :external_id, index: { unique: true }, null: false
      t.bigint :user_external_id, null: false
      t.date :date, null: false

      t.timestamps
    end
  end
end
