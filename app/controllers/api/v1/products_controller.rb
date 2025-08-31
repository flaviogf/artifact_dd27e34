# frozen_string_literal: true

module Api
  module V1
    class ProductsController < ApplicationController
      def index
        page = params[:page]
        per_page = params[:per_page]

        if page.present? && page.to_i <= 0
          return render json: { error: I18n.t('products.errors.invalid_page') }, status: :bad_request
        end

        if per_page.present? && per_page.to_i <= 0
          return render json: { error: I18n.t('products.errors.invalid_per_page') }, status: :bad_request
        end

        products = ActiveRecord::Base.connected_to(role: :reading) do
          Product.order(:id)
                 .page(page)
                 .per(per_page)
                 .pluck(Arel.sql('id AS product_id'), Arel.sql('price_cents / 100.0 AS value'))
                 .collect { |product_id, value| { product_id:, value: } }
        end

        render json: products
      end
    end
  end
end
