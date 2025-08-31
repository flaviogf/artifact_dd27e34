# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  describe 'GET /index' do
    let!(:orders) do
      users.flat_map { |user| create_list(:order, 2, user:) }
    end

    let(:users) { create_list(:user, 50) }

    it 'returns a list of users' do
      get '/api/v1/users'

      expected_users = build_expected_users(users, orders).first(25)

      expect(response.parsed_body).to match_array(expected_users)
    end

    context 'with page' do
      let(:page) { 2 }

      it 'returns a list of users for the specified page' do
        get '/api/v1/users', params: { page: }

        expected_users = build_expected_users(users, orders).slice(25, 25)

        expect(response.parsed_body).to match_array(expected_users)
      end
    end

    context 'with per_page' do
      let(:per_page) { 10 }

      it 'returns a list of users with the specified per_page' do
        get '/api/v1/users', params: { per_page: }

        expected_users = build_expected_users(users, orders).first(per_page)

        expect(response.parsed_body).to match_array(expected_users)
      end
    end

    context 'with invalid page' do
      it 'returns a 400 status code' do
        get '/api/v1/users', params: { page: 'invalid' }

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message' do
        get '/api/v1/users', params: { page: 'invalid' }

        expect(response.parsed_body['error']).to eq('Invalid page')
      end
    end

    context 'with invalid per_page' do
      it 'returns a 400 status code' do
        get '/api/v1/users', params: { per_page: 'invalid' }

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message' do
        get '/api/v1/users', params: { per_page: 'invalid' }

        expect(response.parsed_body['error']).to eq('Invalid per_page')
      end
    end

    private

    def build_expected_users(users, orders)
      grouped_orders = orders.group_by(&:user_id)

      users
        .sort_by(&:id)
        .collect do |user|
          orders = grouped_orders[user.id].collect do |order|
            { 'order_id' => order.id, 'date' => order.date.to_s, 'total' => '0.00', 'products' => match_array([]) }
          end

          { 'user_id' => user.id, 'name' => user.name, 'orders' => match_array(orders) }
        end
    end
  end
end
