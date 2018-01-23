class AddInvoiceNumberToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :invoice_number, :string
    add_index :orders, :invoice_number, unique: true
  end
end
