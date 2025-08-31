# frozen_string_literal: true

module Api
  module V1
    class OrdersController < ApplicationController
      def index
        page = params[:page]
        per_page = params[:per_page]

        if page.present? && page.to_i <= 0
          return render json: { error: I18n.t('orders.errors.invalid_page') }, status: :bad_request
        end

        if per_page.present? && per_page.to_i <= 0
          return render json: { error: I18n.t('orders.errors.invalid_per_page') }, status: :bad_request
        end

        orders = ActiveRecord::Base.connected_to(role: :reading) do
          Order
            .select(
              'orders.id AS order_id',
              'orders.date AS date',
              "to_char(SUM(order_items.price_cents) / 100.0, 'FM999999999.00') AS total",
              "json_agg(json_build_object('product_id', order_items.product_id, 'value', to_char(order_items.price_cents / 100.0, 'FM999999999.00'))) AS products"
            )
            .joins(:order_items)
            .group('orders.id', 'orders.date')
            .order(:id)
            .page(page)
            .per(per_page)
            .collect { |o| { order_id: o.order_id, date: o.date, total: o.total, products: o.products } }
        end

        render json: orders
      end
    end
  end
end
