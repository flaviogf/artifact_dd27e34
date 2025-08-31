# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Products', type: :request do
  describe 'GET /index' do
    let!(:products) { create_list(:product, 50) }

    it 'returns a list of products' do
      get '/api/v1/products'

      expected_products = products
                          .sort_by(&:id)
                          .first(25)
                          .collect { |p| { 'product_id' => p.id, 'value' => (p.price_cents / 100.0).to_s } }

      expect(response.parsed_body).to match_array(expected_products)
    end

    context 'with page' do
      let(:page) { 2 }

      it 'returns a list of products for the specified page' do
        get '/api/v1/products', params: { page: }

        expected_products = products
                            .sort_by(&:id)
                            .slice(25, 25)
                            .collect { |p| { 'product_id' => p.id, 'value' => (p.price_cents / 100.0).to_s } }

        expect(response.parsed_body).to match_array(expected_products)
      end
    end

    context 'with per_page' do
      let(:per_page) { 10 }

      it 'returns a list of products with the specified per_page' do
        get '/api/v1/products', params: { per_page: }

        expected_products = products
                            .sort_by(&:id)
                            .first(per_page)
                            .collect { |p| { 'product_id' => p.id, 'value' => (p.price_cents / 100.0).to_s } }

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
  end
end
