# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.bigint :user_id, null: false
      t.date :date, null: false

      t.timestamps
    end
  end
end
