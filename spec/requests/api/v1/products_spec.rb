# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Products', type: :request do
  describe 'GET /index' do
    let!(:products) { create_list(:product, 50) }

    it 'returns a list of products' do
      get '/api/v1/products'

      expected_products = build_expected_products(products).first(25)

      expect(response.parsed_body).to match_array(expected_products)
    end

    context 'with page' do
      let(:page) { 2 }

      it 'returns a list of products for the specified page' do
        get '/api/v1/products', params: { page: }

        expected_products = build_expected_products(products).slice(25, 25)

        expect(response.parsed_body).to match_array(expected_products)
      end
    end

    context 'with per_page' do
      let(:per_page) { 10 }

      it 'returns a list of products with the specified per_page' do
        get '/api/v1/products', params: { per_page: }

        expected_products = build_expected_products(products).first(per_page)

        expect(response.parsed_body).to match_array(expected_products)
      end
    end

    context 'with invalid page' do
      it 'returns a 400 status code' do
        get '/api/v1/products', params: { page: 'invalid' }

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message' do
        get '/api/v1/products', params: { page: 'invalid' }

        expect(response.parsed_body['error']).to eq('Invalid page')
      end
    end

    context 'with invalid per_page' do
      it 'returns a 400 status code' do
        get '/api/v1/products', params: { per_page: 'invalid' }

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message' do
        get '/api/v1/products', params: { per_page: 'invalid' }

        expect(response.parsed_body['error']).to eq('Invalid per_page')
      end
    end

    private

    def build_expected_products(products)
      products
        .sort_by(&:id)
        .collect { |p| { 'product_id' => p.id, 'value' => format('%0.2f', p.price_cents / 100.0) } }
    end
  end
end
