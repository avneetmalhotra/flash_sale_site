class Admin::Report::DealsReportController < Admin::Report::BaseController

  def index
    @deals = Deal.order_by(params[:order_by])
  end
end
