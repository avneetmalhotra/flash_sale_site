class AddInvoiceNumberToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :invoice_number, :string
  end
end
