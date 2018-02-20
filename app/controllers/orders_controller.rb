class OrdersController < ApplicationController

  before_action :get_order, only: [:destroy, :show, :cancel]

  def cart
  end

  def destroy
    if @order.destroy
      redirect_to root_path, notice: I18n.t(:cart_emptied, scope: [:flash, :notice])
    else
      redirect_to cart_path, alert: @order.pretty_errors
    end
  end

  def show
  end

  def index
    @ready_for_delivery_orders = current_user.orders.ready_for_delivery.order(completed_at: :desc)
    @delivered_orders = current_user.orders.delivered.order(delivered_at: :desc)
    @cancelled_orders = current_user.orders.cancelled.order(cancelled_at: :desc)
  end

  def cancel
    begin
      @order.cancelled_by!(current_user)
      flash[:notice] = I18n.t(:order_successfully_cancelled, scope: [:flash, :notice])
    rescue => e
      flash[:alert] = e.message
    end
    redirect_to order_path(@order)
  end
  

  private

    def get_order
      @order = current_user.orders.find_by(invoice_number: params[:invoice_number])
      unless @order.present?
        render_404 
      end
    end

end
