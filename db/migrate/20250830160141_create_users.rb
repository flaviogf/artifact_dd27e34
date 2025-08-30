# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.bigint :external_id, index: { unique: true }, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
