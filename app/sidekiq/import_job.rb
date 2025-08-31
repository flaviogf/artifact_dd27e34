# frozen_string_literal: true

class ImportJob
  include Sidekiq::Job

  sidekiq_options queue: :imports, retry: 5

  def initialize(reader: Orders::Reader.new)
    @reader = reader
  end

  def perform(import_id)
    import = Import.find_by(id: import_id)
    return if import.blank?

    users, products, orders, order_items = @reader.read(import.file)

    User.upsert_all(users)
    Product.upsert_all(products)
    Order.upsert_all(orders)
    OrderItem.upsert_all(order_items, unique_by: %i[order_id product_id price_cents])
  end
end
