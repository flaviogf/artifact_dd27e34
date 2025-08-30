# frozen_string_literal: true

class CreateImports < ActiveRecord::Migration[8.0]
  def change
    create_table :imports do |t|
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
