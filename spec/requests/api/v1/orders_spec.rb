# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Imports', type: :request do
  describe 'POST /create' do
    let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/data_1.txt'), 'text/plain') }

    it 'creates a new import' do
      expect do
        post '/api/v1/imports', params: { file: }
      end.to change(Import, :count).by(1)
    end

    it 'returns a 201 status code' do
      post '/api/v1/imports', params: { file: }

      expect(response).to have_http_status(:created)
    end

    it 'returns the import ID in the response' do
      post '/api/v1/imports', params: { file: }

      import_id = response.parsed_body['import_id']

      expect(import_id).to eq(Import.last.id)
    end

    it 'attaches the uploaded file to the import' do
      post '/api/v1/imports', params: { file: }

      import = Import.find(response.parsed_body['import_id'])

      expect(import.file).to be_attached
    end

    it 'enqueues the ImportJob' do
      expect do
        post '/api/v1/imports', params: { file: }
      end.to change(ImportJob.jobs, :size).by(1)
    end

    context 'when no file is provided' do
      it 'returns a 400 status code' do
        post '/api/v1/imports', params: {}

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message' do
        post '/api/v1/imports', params: {}

        expect(response.parsed_body['error']).to eq('File is required')
      end
    end

    context 'when an invalid file is provided' do
      it 'returns a 422 status code' do
        post '/api/v1/imports', params: { file: 'invalid_file' }

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'returns an error message' do
        post '/api/v1/imports', params: { file: 'invalid_file' }

        expect(response.parsed_body['error']).to eq('Invalid file')
      end
    end

    context 'when a non-text file is provided' do
      let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/rails.png'), 'image/png') }

      it 'returns a 415 status code' do
        post '/api/v1/imports', params: { file: }

        expect(response).to have_http_status(:unsupported_media_type)
      end

      it 'returns an error message' do
        post '/api/v1/imports', params: { file: }

        expect(response.parsed_body['error']).to eq('Invalid file type')
      end
    end
  end
end
