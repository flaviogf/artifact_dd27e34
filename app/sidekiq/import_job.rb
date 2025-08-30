# frozen_string_literal: true

class ImportJob
  include Sidekiq::Job

  sidekiq_options queue: :imports, retry: 5

  def perform(import_id)
    import = Import.find_by(id: import_id)
    return if import.blank?

    users = {}
    products = {}
    orders = {}

    import.file.open do |file|
      file.each_line do |line|
        user_id = line[0...10].to_i
        user_name = line[10...55].strip
        order_id = line[55...65].to_i
        product_id = line[65...75].to_i
        product_price_cents = line[75...87].strip.gsub(/\./, '').to_i
        order_date = Date.strptime(line[87...95], '%Y%m%d')

        users[user_id] = { external_id: user_id, name: user_name }
        products[product_id] = { external_id: product_id, price_cents: product_price_cents }
        orders[order_id] = { external_id: order_id, user_external_id: user_id, date: order_date }
      end
    end

    User.upsert_all(users.values, unique_by: :external_id)
    Product.upsert_all(products.values, unique_by: :external_id)
    Order.upsert_all(orders.values, unique_by: :external_id)
  end
end
