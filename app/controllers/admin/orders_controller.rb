class Admin::OrdersController < Admin::BaseController

  before_action :get_order, only: [:show, :cancel, :deliver]

  def index
    if params[:user].present? && params[:user][:email].present?
      @orders = Order.joins(:user).where("email LIKE ?", "%#{params[:user][:email]}%")
    else
      @orders = Order.all
    end  
    @ready_for_delivery_orders = @orders.ready_for_delivery.order(completed_at: :desc)
    @delivered_orders = @orders.delivered.order(delivered_at: :desc)
    @cancelled_orders = @orders.cancelled.order(cancelled_at: :desc)
  end

  def show
    
  end

  def cancel
    if @order.cancel(current_user)
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
    @ready_for_delivery_orders = @orders.ready_for_delivery.order(completed_at: :desc)
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

end
