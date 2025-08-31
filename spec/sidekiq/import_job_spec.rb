# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportJob, type: :job do
  describe '#perform' do
    subject(:job) { described_class.new }

    let(:import) { create(:import) }

    let(:users) do
      [
        { id: 99, name: 'Junita Jast' },
        { id: 77, name: 'Mrs. Stephen Trantow' },
        { id: 19, name: 'Teresa Brakus' },
        { id: 52, name: 'Britt Armstrong' }
      ]
    end

    let(:products) do
      [
        { id: 4, price_cents: 87_024 },
        { id: 2, price_cents: 73_857 },
        { id: 3, price_cents: 184_386 },
        { id: 1, price_cents: 121_307 }
      ]
    end

    let(:orders) do
      [
        { id: 1068, user_id: 99, date: Date.new(2021, 11, 25) },
        { id: 840, user_id: 77, date: Date.new(2021, 5, 21) },
        { id: 192, user_id: 19, date: Date.new(2021, 3, 25) },
        { id: 559, user_id: 52, date: Date.new(2021, 9, 2) }
      ]
    end

    let(:order_items) do
      [
        { order_id: 1068, product_id: 4, price_cents: 87_024 },
        { order_id: 1068, product_id: 2, price_cents: 73_857 },
        { order_id: 1068, product_id: 2, price_cents: 73_957 },
        { order_id: 840, product_id: 2, price_cents: 73_857 },
        { order_id: 192, product_id: 3, price_cents: 184_386 },
        { order_id: 559, product_id: 1, price_cents: 121_307 }
      ]
    end

    before do
      import.file.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/data_1.txt')),
        filename: 'data_1.txt'
      )
    end

    it 'imports the users' do
      job.perform(import.id)

      expected_users = users.collect { |attrs| have_attributes(attrs) }

      expect(User.all).to match_array(expected_users)
    end

    it 'imports the products' do
      job.perform(import.id)

      expected_products = products.collect { |attrs| have_attributes(attrs) }

      expect(Product.all).to match_array(expected_products)
    end

    it 'imports the orders' do
      job.perform(import.id)

      expected_orders = orders.collect { |attrs| have_attributes(attrs) }

      expect(Order.all).to match_array(expected_orders)
    end

    it 'imports the order items' do
      job.perform(import.id)

      expected_order_items = order_items.collect { |attrs| have_attributes(attrs) }

      expect(OrderItem.all).to match_array(expected_order_items)
    end

    it 'updates the import status to completed' do
      expect do
        job.perform(import.id)
      end.to change { import.reload.status }.from('pending').to('completed')
    end

    context 'when the file contains users that have already been imported' do
      let(:import_with_imported_users) { create(:import) }

      let(:users) do
        [
          { id: 99, name: 'Junita Last' },
          { id: 77, name: 'Mrs. Stephen Trantow' },
          { id: 19, name: 'Teresa Brakus' },
          { id: 52, name: 'Britt Armstrong' }
        ]
      end

      before do
        import_with_imported_users.file.attach(
          io: File.open(Rails.root.join('spec/fixtures/files/data_2.txt')),
          filename: 'data_2.txt'
        )

        job.perform(import.id)
      end

      it 'updates the existing users' do
        job.perform(import_with_imported_users.id)

        expected_users = users.collect { |attrs| have_attributes(attrs) }

        expect(User.all).to match_array(expected_users)
      end
    end

    context 'when the file contains products that have already been imported' do
      let(:import_with_imported_products) { create(:import) }

      let(:products) do
        [
          { id: 4, price_cents: 97_024 },
          { id: 2, price_cents: 73_857 },
          { id: 3, price_cents: 184_386 },
          { id: 1, price_cents: 121_307 }
        ]
      end

      before do
        import_with_imported_products.file.attach(
          io: File.open(Rails.root.join('spec/fixtures/files/data_2.txt')),
          filename: 'data_2.txt'
        )

        job.perform(import.id)
      end

      it 'updates the existing products' do
        job.perform(import_with_imported_products.id)

        expected_products = products.collect { |attrs| have_attributes(attrs) }

        expect(Product.all).to match_array(expected_products)
      end
    end

    context 'when the file contains orders that have already been imported' do
      let(:import_with_imported_orders) { create(:import) }

      let(:orders) do
        [
          { id: 1068, user_id: 99, date: Date.new(2021, 11, 26) },
          { id: 840, user_id: 77, date: Date.new(2021, 5, 21) },
          { id: 192, user_id: 19, date: Date.new(2021, 3, 25) },
          { id: 559, user_id: 52, date: Date.new(2021, 9, 2) }
        ]
      end

      before do
        import_with_imported_orders.file.attach(
          io: File.open(Rails.root.join('spec/fixtures/files/data_2.txt')),
          filename: 'data_2.txt'
        )

        job.perform(import.id)
      end

      it 'updates the existing orders' do
        job.perform(import_with_imported_orders.id)

        expected_orders = orders.collect { |attrs| have_attributes(attrs) }

        expect(Order.all).to match_array(expected_orders)
      end
    end

    context 'when the file contains order items that have already been imported' do
      let(:import_with_imported_order_items) { create(:import) }

      let(:order_items) do
        [
          { order_id: 1068, product_id: 4, price_cents: 87_024 },
          { order_id: 1068, product_id: 2, price_cents: 73_857 },
          { order_id: 1068, product_id: 2, price_cents: 73_957 },
          { order_id: 840, product_id: 2, price_cents: 73_857 },
          { order_id: 192, product_id: 3, price_cents: 184_386 },
          { order_id: 559, product_id: 1, price_cents: 121_307 },
          { order_id: 1068, product_id: 4, price_cents: 97_024 }
        ]
      end

      before do
        import_with_imported_order_items.file.attach(
          io: File.open(Rails.root.join('spec/fixtures/files/data_2.txt')),
          filename: 'data_2.txt'
        )

        job.perform(import.id)
      end

      it 'updates the existing order items' do
        job.perform(import_with_imported_order_items.id)

        expected_order_items = order_items.collect { |attrs| have_attributes(attrs) }

        expect(OrderItem.all).to match_array(expected_order_items)
      end
    end

    context "when the import doesn't exist" do
      it "doesn't import any user" do
        expect do
          job.perform(0)
        end.not_to change(User, :count)
      end

      it "doesn't import any product" do
        expect do
          job.perform(0)
        end.not_to change(Product, :count)
      end

      it "doesn't import any order" do
        expect do
          job.perform(0)
        end.not_to change(Order, :count)
      end

      it "doesn't import any order item" do
        expect do
          job.perform(0)
        end.not_to change(OrderItem, :count)
      end
    end

    context "when the import file doesn't exist" do
      let(:import_without_file) { create(:import) }

      it "doesn't import any user" do
        expect do
          job.perform(0)
        end.not_to change(User, :count)
      end

      it "doesn't import any product" do
        expect do
          job.perform(0)
        end.not_to change(Product, :count)
      end

      it "doesn't import any order" do
        expect do
          job.perform(0)
        end.not_to change(Order, :count)
      end

      it "doesn't import any order item" do
        expect do
          job.perform(0)
        end.not_to change(OrderItem, :count)
      end
    end

    context 'when all retries are exhausted' do
      it 'updates the import status to failed' do
        expect do
          job = { 'args' => [import.id] }
          ex = StandardError.new('Some error')

          ImportJob.sidekiq_retries_exhausted_block.call(job, ex)
        end.to change { import.reload.status }.from('pending').to('failed')
      end
    end
  end
end
