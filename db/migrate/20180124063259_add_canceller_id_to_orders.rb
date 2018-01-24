class AddCancellerIdToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :canceller_id, :integer
  end
end
