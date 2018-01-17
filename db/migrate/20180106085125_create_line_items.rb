class CreateLineItems < ActiveRecord::Migration[5.1]
  def change
    create_table :line_items do |t|
      t.integer :quantity, default: 1
      t.decimal :discount_price, precision: 8, scale: 2
      t.decimal :price, precision: 8, scale: 2      

      t.references :deal, foreign_key: true
      t.references :order, foreign_key: true

      t.timestamps
    end
  end
end
