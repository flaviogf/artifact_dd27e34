# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Imports', type: :request do
  describe 'GET /index' do
    let!(:imports) { create_list(:import, 50) }

    it 'returns a list of imports' do
      get '/api/v1/imports'

      expected_imports = imports
                         .sort_by(&:created_at)
                         .first(25)
                         .collect { |i| { 'import_id' => i.id, 'status' => i.status } }

      expect(response.parsed_body).to match_array(expected_imports)
    end

    context 'with page' do
      let(:page) { 2 }

      it 'returns a list of imports for the specified page' do
        get '/api/v1/imports', params: { page: }

        expected_imports = imports
                           .sort_by(&:created_at)
                           .slice(25, 25)
                           .collect { |i| { 'import_id' => i.id, 'status' => i.status } }

        expect(response.parsed_body).to match_array(expected_imports)
      end
    end

    context 'with per_page' do
      let(:per_page) { 10 }

      it 'returns a list of imports with the specified per_page' do
        get '/api/v1/imports', params: { per_page: }

        expected_imports = imports
                           .sort_by(&:created_at)
                           .first(10)
                           .collect { |i| { 'import_id' => i.id, 'status' => i.status } }

        expect(response.parsed_body).to match_array(expected_imports)
      end
    end

    context 'with invalid page' do
      it 'returns a 400 status code' do
        get '/api/v1/imports', params: { page: 'invalid' }

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message' do
        get '/api/v1/imports', params: { page: 'invalid' }

        expect(response.parsed_body['error']).to eq('Invalid page')
      end
    end

    context 'with invalid per_page' do
      it 'returns a 400 status code' do
        get '/api/v1/imports', params: { per_page: 'invalid' }

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message' do
        get '/api/v1/imports', params: { per_page: 'invalid' }

        expect(response.parsed_body['error']).to eq('Invalid per_page')
      end
    end
  end

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
