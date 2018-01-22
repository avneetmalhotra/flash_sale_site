class CreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments do |t|
      t.string :charge_id
      t.decimal :amount, precision: 8, scale: 2
      t.string :currency
      t.string :failure_code
      t.string :status
      t.integer :user_id

      t.timestamps
    end
  end
end
