class Admin::OrdersController < Admin::BaseController

  before_action :fetch_orders, only: :index
  before_action :get_order, only: [:show, :cancel, :deliver]

  def index
    @ready_for_delivery_orders = @orders.ready_for_delivery.order(completed_at: :desc)
    @delivered_orders = @orders.delivered.order(delivered_at: :desc)
    @cancelled_orders = @orders.cancelled.order(cancelled_at: :desc)
  end

  def show
    
  end

  def cancel
    begin
      @order.cancelled_by!(current_user)
      flash[:notice] = I18n.t(:order_successfully_cancelled, scope: [:flash, :notice])
    rescue => e
      flash[:alert] = e.message
    end
    redirect_to admin_order_path(@order)
  end

  def deliver
    if @order.deliver
      flash[:notice] = I18n.t(:order_successfully_marked_delivered, scope: [:flash, :notice])
    else
      flash[:alert] = @order.pretty_errors
    end
    redirect_to admin_order_path(@order)
  end


  private

    def get_order
      @order = Order.find_by(invoice_number: params[:invoice_number])
      if @order.nil?
        render_404
      end
    end

    def fetch_orders
      if params[:search].present? && params[:search][:email].present?
        @orders = Order.search_by_email(params[:search][:email])
      else
        @orders = Order.all
      end 
    end

end
