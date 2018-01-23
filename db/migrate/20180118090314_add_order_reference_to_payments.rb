class AddOrderReferenceToPayments < ActiveRecord::Migration[5.1]
  def change
    add_reference :payments, :order, foreign_key: true
  end
end
