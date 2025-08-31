# frozen_string_literal: true

module Api
  module V1
    class ImportsController < ApplicationController
      def index
        page = params[:page]
        per_page = params[:per_page]

        if page.present? && page.to_i <= 0
          return render json: { error: I18n.t('imports.errors.invalid_page') }, status: :bad_request
        end

        if per_page.present? && per_page.to_i <= 0
          return render json: { error: I18n.t('imports.errors.invalid_per_page') }, status: :bad_request
        end

        imports = ActiveRecord::Base.connected_to(role: :reading) do
          Import
            .select('id AS import_id', 'status')
            .order(:created_at)
            .page(page)
            .per(per_page)
            .as_json(except: %i[id])
        end

        render json: imports
      end

      def create
        unless params[:file].present?
          return render json: { error: I18n.t('imports.errors.missing_file') }, status: :bad_request
        end

        unless params[:file].is_a?(ActionDispatch::Http::UploadedFile)
          return render json: { error: I18n.t('imports.errors.invalid_file') }, status: :unprocessable_content
        end

        unless params[:file].content_type == 'text/plain'
          return render json: { error: I18n.t('imports.errors.invalid_file_type') }, status: :unsupported_media_type
        end

        import = Import.create!(status: :pending)
        import.file.attach(params[:file])

        ImportJob.perform_async(import.id)

        render json: { import_id: import.id }, status: :created
      end

      def show
        import = Import.find(params[:id])

        render json: { import_id: import.id, status: import.status }
      end
    end
  end
end
