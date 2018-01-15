class AddLoyaltyDiscountToLineItems < ActiveRecord::Migration[5.1]
  def change
    add_column :line_items, :loyalty_discount, :decimal 
  end
end
