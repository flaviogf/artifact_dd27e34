# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      def index
        page = params[:page]
        per_page = params[:per_page]
        order_start_date = parse_date(params[:order_start_date], Time.at(0).to_date)
        order_end_date = parse_date(params[:order_end_date], Time.zone.today)

        if page.present? && page.to_i <= 0
          return render json: { error: I18n.t('users.errors.invalid_page') }, status: :bad_request
        end

        if per_page.present? && per_page.to_i <= 0
          return render json: { error: I18n.t('users.errors.invalid_per_page') }, status: :bad_request
        end

        if order_start_date > order_end_date
          return render json: { error: I18n.t('users.errors.invalid_date_range') }, status: :bad_request
        end

        users = fetch_users(page, per_page, order_start_date, order_end_date)

        render json: users
      end

      private

      def parse_date(date_str, default)
        Date.parse(date_str)
      rescue StandardError
        default
      end

      def fetch_users(page, per_page, order_start_date, order_end_date)
        ActiveRecord::Base.connected_to(role: :reading) do
          query = User
                  .select(
                    'users.id AS user_id',
                    'users.name',
                    <<~SQL.squish
                      COALESCE(
                        json_agg(
                          json_build_object(
                            'order_id', orders.id,
                            'date', orders.date,
                            'total', orders.total,
                            'products', orders.products
                          )
                        ) FILTER (WHERE orders.id IS NOT NULL),
                        '[]'
                      ) AS orders_data
                    SQL
                  )
                  .joins(
                    <<~SQL.squish
                      LEFT JOIN (
                        SELECT
                          orders.id,
                          orders.user_id,
                          orders.date,
                          COALESCE(
                            to_char(SUM(order_items.price_cents) / 100.0, 'FM999999999.00'),
                            '0.00'
                          ) AS total,
                          COALESCE(
                            json_agg(
                              json_build_object(
                                'product_id', order_items.product_id,
                                'value', to_char(order_items.price_cents / 100.0, 'FM999999999.00')
                              )
                            ) FILTER (WHERE order_items.product_id IS NOT NULL),
                            '[]'
                          ) AS products
                        FROM
                          orders
                        LEFT JOIN
                          order_items ON order_items.order_id = orders.id
                        GROUP BY
                          orders.id, orders.user_id, orders.date
                      ) AS orders ON orders.user_id = users.id
                    SQL
                  )
                  .group('users.id', 'users.name')
                  .order(:id)
                  .page(page)
                  .per(per_page)

          query = query.where('orders.date >= ?', order_start_date) if order_start_date.present?
          query = query.where('orders.date <= ?', order_end_date) if order_end_date.present?

          query.collect { |user| user.as_json(except: %i[id orders_data]).merge('orders' => user.orders_data) }
        end
      end
    end
  end
end
