class Admin::OrdersController < Admin::BaseController

  before_action :get_order, only: [:show, :cancel, :deliver]
  before_action :fetch_orders, only: :browse

  def index
    @open_orders = Order.open.order(completed_at: :desc)
    @delivered_orders = Order.delivered.order(delivered_at: :desc)
    @cancelled_orders = Order.cancelled.order(cancelled_at: :desc)
  end

  def show
    
  end

  def cancel
    if @order.cancel_by_admin    
      flash[:notice] = I18n.t(:order_successfully_cancelled, scope: [:flash, :notice])
    else
      flash[:alert] = I18n.t(:order_cannot_be_cancelled, scope: [:flash, :alert]) + '<br>' + @order.pretty_errors
    end
    redirect_to admin_order_path(@order)
  end

  def deliver
    if @order.deliver
      flash[:notice] = I18n.t(:order_successfully_marked_delivered, scope: [:flash, :notice])
    else
      flash[:alert] = I18n.t(:order_cannot_be_marked_delivered, scope: [:flash, :alert]) + '<br>' + @order.pretty_errors
    end
    redirect_to admin_order_path(@order)
  end

  def browse
    @open_orders = @orders.open.order(completed_at: :desc)
    @delivered_orders = @orders.delivered.order(delivered_at: :desc)
    @cancelled_orders = @orders.cancelled.order(cancelled_at: :desc)
    render 'index'
  end

  private

    def get_order
      @order = Order.find_by(invoice_number: params[:invoice_number])
      if @order.nil?
        render_404
      end
    end

    def fetch_orders
      if params[:user][:email].present?
        @orders = Order.joins(:user).where("email LIKE ?", "%#{params[:user][:email]}%")
      else
        redirect_to admin_orders_path, alert: I18n.t(:empty_email_argument, scope: [:flash, :alert])
      end
    end
end
