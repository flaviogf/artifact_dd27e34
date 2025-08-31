# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      def index
        page = params[:page]
        per_page = params[:per_page]

        if page.present? && page.to_i <= 0
          return render json: { error: I18n.t('users.errors.invalid_page') }, status: :bad_request
        end

        if per_page.present? && per_page.to_i <= 0
          return render json: { error: I18n.t('users.errors.invalid_per_page') }, status: :bad_request
        end

        users = User
                .select('id AS user_id', 'name')
                .order(:id)
                .page(page)
                .per(per_page)
                .collect { |u| { user_id: u.user_id, name: u.name } }

        render json: users
      end
    end
  end
end
