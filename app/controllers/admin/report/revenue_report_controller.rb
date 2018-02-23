class Admin::Report::RevenueReportController < Admin::Report::BaseController

  def index
    @deals =  Deal.left_joins(line_items: :order).select(:id, :title, :price, :discount_price, 'sum(line_items.quantity) as quantity_ordered', 'count(line_items.id) as unique_orders', 'sum(line_items.total_amount) as revenue_generated').where(orders: { state: [:completed, :delivered, nil] }).group(:id)
  end
end
