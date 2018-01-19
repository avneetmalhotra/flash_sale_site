class CreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments do |t|
      t.string :amount
      t.string :currency, default: 'usd'
      t.integer :customer_id

      t.timestamps
    end
  end
end
