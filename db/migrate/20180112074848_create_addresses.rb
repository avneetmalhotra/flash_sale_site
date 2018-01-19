class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|

      t.string :house_number
      t.string :street
      t.string :city
      t.string :state
      t.string :country
      t.integer :pincode

      t.timestamps
    end
  end
end
