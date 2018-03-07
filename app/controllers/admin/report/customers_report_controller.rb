class Admin::Report::CustomersReportController < Admin::Report::BaseController

  def index
    @customers = User.all
  end
end
