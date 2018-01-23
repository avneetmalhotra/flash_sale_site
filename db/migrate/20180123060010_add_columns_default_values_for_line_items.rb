class AddColumnsDefaultValuesForLineItems < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:line_items, :discount_price, from: nil, to: 0.01)
    change_column_default(:line_items, :price, from: nil, to: 0.01)
    change_column_default(:line_items, :loyalty_discount, from: nil, to: 0)
    change_column_default(:line_items, :total_amount, from: nil, to: 0)
  end
end
