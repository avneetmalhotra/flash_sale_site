class CreateDeals < ActiveRecord::Migration[5.1]
  def change
    create_table :deals do |t|
      t.string :title
      t.text :description
      t.decimal :price, precision: 8, scale: 2
      t.decimal :discount_price, precision: 8, scale: 2
      t.integer :quantity
      t.date :publishing_date
      t.datetime :publish_start_at
      t.datetime :publish_end_at

      t.timestamps
    end
  end
end
