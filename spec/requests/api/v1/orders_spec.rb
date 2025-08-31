# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Orders', type: :request do
  describe 'GET /index' do
    let!(:order_items) do
      orders.flat_map { |order| create_list(:order_item, 2, order:) }
    end

    let(:orders) do
      create_list(:order, 50)
    end

    it 'returns a list of orders' do
      get '/api/v1/orders'

      expected_orders = build_expected_orders(orders, order_items).first(25)

      expect(response.parsed_body).to match_array(expected_orders)
    end

    context 'with page' do
      let(:page) { 2 }

      it 'returns a list of orders for the specified page' do
        get '/api/v1/orders', params: { page: }

        expected_orders = build_expected_orders(orders, order_items).slice(25, 25)

        expect(response.parsed_body).to match_array(expected_orders)
      end
    end

    context 'with per_page' do
      let(:per_page) { 10 }

      it 'returns a list of orders with the specified per_page' do
        get '/api/v1/orders', params: { per_page: }

        expected_orders = build_expected_orders(orders, order_items).first(per_page)

        expect(response.parsed_body).to match_array(expected_orders)
      end
    end

    context 'with start_date' do
      let(:start_date) { 10.days.ago.to_date }

      before do
        orders[0...40].each { |order| order.update(date: 20.days.ago.to_date) }
        orders[40...].each { |order| order.update(date: 5.days.ago.to_date) }
      end

      it 'returns a list of orders from the specified start_date' do
        get '/api/v1/orders', params: { start_date: }

        expected_orders = build_expected_orders(orders[40...], order_items).first(25)

        expect(response.parsed_body).to match_array(expected_orders)
      end
    end

    context 'with end_date' do
      let(:end_date) { Time.current.to_date }

      before do
        orders[0...40].each { |order| order.update(date: 20.days.from_now.to_date) }
        orders[40...].each { |order| order.update(date: 5.days.ago.to_date) }
      end

      it 'returns a list of orders up to the specified end_date' do
        get '/api/v1/orders', params: { end_date: }

        expected_orders = build_expected_orders(orders[40...], order_items).first(25)

        expect(response.parsed_body).to match_array(expected_orders)
      end
    end

    context 'when start_date is after end_date' do
      let(:start_date) { 10.days.from_now.to_date }

      let(:end_date) { Time.current.to_date }

      it 'returns a 400 status code' do
        get '/api/v1/orders', params: { start_date:, end_date: }

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message' do
        get '/api/v1/orders', params: { start_date:, end_date: }

        expect(response.parsed_body['error']).to eq('Invalid date range')
      end
    end

    context 'with invalid page' do
      it 'returns a 400 status code' do
        get '/api/v1/orders', params: { page: 'invalid' }

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message' do
        get '/api/v1/orders', params: { page: 'invalid' }

        expect(response.parsed_body['error']).to eq('Invalid page')
      end
    end

    context 'with invalid per_page' do
      it 'returns a 400 status code' do
        get '/api/v1/orders', params: { per_page: 'invalid' }

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message' do
        get '/api/v1/orders', params: { per_page: 'invalid' }

        expect(response.parsed_body['error']).to eq('Invalid per_page')
      end
    end

    private

    def build_expected_orders(orders, order_items)
      grouped_order_items = order_items.group_by(&:order_id)

      orders.sort_by(&:id).each_with_object([]) do |order, memo|
        result = build_expected_order(grouped_order_items, order)

        memo << {
          'order_id' => order.id,
          'date' => order.date.to_s,
          'total' => format('%0.2f', result[:total] / 100.0),
          'products' => match_array(result[:products])
        }
      end
    end

    def build_expected_order(grouped_order_items, order)
      grouped_order_items[order.id].each_with_object(products: [], total: 0) do |item, memo|
        memo[:products] << { 'product_id' => item.product_id, 'value' => format('%0.2f', item.price_cents / 100.0) }
        memo[:total] += item.price_cents
      end
    end
  end
end
