class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.decimal :amount, precision: 8, scale: 2
      t.decimal :loyalty_discount, precision: 3, scale: 2

      t.references :user, foreign_key: true

      t.string :state
    
      t.timestamps
    end
  end
end
