class AddColumnsToLineItems < ActiveRecord::Migration[5.1]
  def change
    add_column :line_items, :loyalty_discount, :decimal, precision: 8, scale: 2
    add_column :line_items, :total_amount, :decimal, precision: 8, scale: 2
  end
end
