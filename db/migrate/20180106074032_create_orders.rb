class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.decimal :total_amount, precision: 10, scale: 2, default: 0
      t.decimal :loyalty_discount, precision: 10, scale: 2, default: 0

      t.references :user, foreign_key: true

      t.string :state
    
      t.timestamps
    end
  end
end
