# frozen_string_literal: true

class Api::V1::ImportsController < ApplicationController
  def index
    page = params[:page]
    per_page = params[:per_page]

    if page.present? && page.to_i <= 0
      return render json: { error: I18n.t('imports.errors.invalid_page') }, status: :bad_request
    end

    if per_page.present? && per_page.to_i <= 0
      return render json: { error: I18n.t('imports.errors.invalid_per_page') }, status: :bad_request
    end

    imports = Import
              .order(:created_at)
              .page(page)
              .per(params[:per_page])
              .pluck(Arel.sql('id AS import_id'), :status)
              .collect { |import_id, status| { import_id:, status: } }

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
end
