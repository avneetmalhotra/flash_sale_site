class Admin::Report::DealsReportController < Admin::Report::BaseController

  def index
    if params[:order_by].present?
      case params[:order_by]
      when 'price_ascending'
        @deals = Deal.order(:price)
      when 'price_descending'
        @deals = Deal.order(price: :desc)
      when 'discount_price_ascending', 'loyalty_discount_ascending'
        @deals = Deal.order(:discount_price)
      when 'discount_price_descending', 'loyalty_discount_descending'
        @deals = Deal.order(discount_price: :desc)
      else
        render_404 and return
      end
    
    else
      @deals = Deal.all
    end
  end
end
