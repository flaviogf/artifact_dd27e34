# frozen_string_literal: true

module Api
  module V1
    class OrdersController < ApplicationController
      def index
        page = params[:page]
        per_page = params[:per_page]
        start_date = parse_date(params[:start_date], Time.at(0).to_date)
        end_date = parse_date(params[:end_date], Time.zone.today)

        if page.present? && page.to_i <= 0
          return render json: { error: I18n.t('orders.errors.invalid_page') }, status: :bad_request
        end

        if per_page.present? && per_page.to_i <= 0
          return render json: { error: I18n.t('orders.errors.invalid_per_page') }, status: :bad_request
        end

        if start_date > end_date
          return render json: { error: I18n.t('orders.errors.invalid_date_range') }, status: :bad_request
        end

        orders = fetch_orders(page, per_page, start_date, end_date)

        render json: orders
      end

      private

      def parse_date(date_str, default)
        Date.parse(date_str)
      rescue StandardError
        default
      end

      def fetch_orders(page, per_page, start_date, end_date)
        ActiveRecord::Base.connected_to(role: :reading) do
          query = Order
                  .select(
                    'orders.id AS order_id',
                    'orders.date AS date',
                    <<~SQL.squish
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
                    SQL
                  )
                  .joins(:order_items)
                  .group('orders.id', 'orders.date')
                  .order(:id)
                  .page(page)
                  .per(per_page)

          query = query.where('orders.date >= ?', start_date) if start_date.present?
          query = query.where('orders.date <= ?', end_date) if end_date.present?

          query.as_json(except: %i[id])
        end
      end
    end
  end
end
