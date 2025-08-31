# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orders::Reader do
  describe '.read' do
    subject(:reader) { described_class.new }

    let(:file) { Rails.root.join('spec/fixtures/files/data_1.txt') }

    it 'returns an array of users' do
      users, = reader.read(file)

      expected_users = [
        { id: 99, name: 'Junita Jast' },
        { id: 77, name: 'Mrs. Stephen Trantow' },
        { id: 19, name: 'Teresa Brakus' },
        { id: 52, name: 'Britt Armstrong' }
      ]

      expect(users).to match_array(expected_users)
    end

    it 'returns an array of products' do
      _, products, = reader.read(file)

      expected_products = [
        { id: 4, price_cents: 87_024 },
        { id: 2, price_cents: 73_857 },
        { id: 3, price_cents: 184_386 },
        { id: 1, price_cents: 121_307 }
      ]

      expect(products).to match_array(expected_products)
    end

    it 'returns an array of orders' do
      _, _, orders, = reader.read(file)

      expected_orders = [
        { id: 1068, user_id: 99, date: Date.new(2021, 11, 25) },
        { id: 840, user_id: 77, date: Date.new(2021, 5, 21) },
        { id: 192, user_id: 19, date: Date.new(2021, 3, 25) },
        { id: 559, user_id: 52, date: Date.new(2021, 9, 2) }
      ]

      expect(orders).to match_array(expected_orders)
    end

    it 'returns an array of order items' do
      _, _, _, order_items = reader.read(file)

      expected_order_items = [
        { order_id: 1068, product_id: 4, price_cents: 87_024 },
        { order_id: 1068, product_id: 2, price_cents: 73_857 },
        { order_id: 1068, product_id: 2, price_cents: 73_957 },
        { order_id: 840, product_id: 2, price_cents: 73_857 },
        { order_id: 192, product_id: 3, price_cents: 184_386 },
        { order_id: 559, product_id: 1, price_cents: 121_307 }
      ]

      expect(order_items).to match_array(expected_order_items)
    end
  end
end
