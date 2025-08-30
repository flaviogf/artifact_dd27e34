# frozen_string_literal: true

class Api::V1::ImportsController < ApplicationController
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
