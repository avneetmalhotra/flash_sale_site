class Admin::Report::RevenueReportController < Admin::Report::BaseController

  def index
    @deals = Deal.all
  end
end
