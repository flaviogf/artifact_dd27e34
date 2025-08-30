# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportJob, type: :job do
  describe '#perform' do
    subject(:job) { described_class.new }

    let(:import) { create(:import) }

    let(:users) do
      [
        { external_id: 99, name: 'Junita Jast' },
        { external_id: 77, name: 'Mrs. Stephen Trantow' },
        { external_id: 19, name: 'Teresa Brakus' },
        { external_id: 52, name: 'Britt Armstrong' }
      ]
    end

    before do
      file = fixture_file_upload(Rails.root.join('spec/fixtures/files/data_1.txt'), 'text/plain')
      import.file.attach(file)
    end

    it 'imports the users' do
      job.perform(import.id)

      expected_users = users.collect { |attrs| have_attributes(attrs) }

      expect(User.all).to match_array(expected_users)
    end

    context 'when the file contains users that have already been imported' do
      let(:import_with_imported_users) { create(:import) }

      let(:users) do
        [
          { external_id: 99, name: 'Junita Last' },
          { external_id: 77, name: 'Mrs. Stephen Trantow' },
          { external_id: 19, name: 'Teresa Brakus' },
          { external_id: 52, name: 'Britt Armstrong' }
        ]
      end

      before do
        file = fixture_file_upload(Rails.root.join('spec/fixtures/files/data_2.txt'), 'text/plain')
        import_with_imported_users.file.attach(file)

        job.perform(import.id)
      end

      it 'updates the existing users' do
        job.perform(import_with_imported_users.id)

        expected_users = users.collect { |attrs| have_attributes(attrs) }

        expect(User.all).to match_array(expected_users)
      end
    end

    context "when the import doesn't exist" do
      it "doesn't import any user" do
        job.perform(0)

        expect(User.count).to eq(0)
      end
    end

    context "when the import file doesn't exist" do
      let(:import_without_file) { create(:import) }

      it "doesn't import any user" do
        job.perform(import_without_file.id)

        expect(User.count).to eq(0)
      end
    end
  end
end
