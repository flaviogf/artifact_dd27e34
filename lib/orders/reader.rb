# frozen_string_literal: true

module Orders
  class Reader
    def read(file)
      users = {}
      products = {}
      orders = {}
      order_items = {}

      file.open do |f|
        f.each_line do |line|
          user_id, user_name, order_id, product_id, product_price_cents, order_date = extract_data_from(line)

          order_items_id = "#{order_id}-#{product_id}-#{product_price_cents}"

          users[user_id] = { id: user_id, name: user_name }
          products[product_id] = { id: product_id, price_cents: product_price_cents }
          orders[order_id] = { id: order_id, user_id: user_id, date: order_date }
          order_items[order_items_id] = { order_id:, product_id:, price_cents: product_price_cents }
        end

        [users.values, products.values, orders.values, order_items.values]
      end
    end

    private

    def extract_data_from(line)
      [
        line[0...10].to_i,
        line[10...55].strip,
        line[55...65].to_i,
        line[65...75].to_i,
        line[75...87].strip.gsub('.', '').to_i,
        Date.strptime(line[87...95], '%Y%m%d')
      ]
    end
  end
end
