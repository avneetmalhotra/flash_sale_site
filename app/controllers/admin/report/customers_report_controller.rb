class Admin::Report::CustomersReportController < Admin::Report::BaseController

  def index
    @customers = User.left_joins(orders: :payments).select(:id, :name, :email, :admin, 'sum(payments.amount) as money_spend').where(orders: { state: [nil, 'completed', 'delivered'] }).group(:id)
  end
end
