class OrdersController < ApplicationController

  before_action :get_order, only: [:destroy, :show, :cancel]
  before_action :get_current_users_open_orders, only: :myorders
  before_action :get_current_users_delivered_orders, only: :myorders
  before_action :get_current_users_cancelled_orders, only: :myorders 

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

  def myorders
  end

  def cancel
    if @order.cancel
      flash[:success] = I18n.t(:successfully_cancelled, scope: [:flash, :notice])
    else
      flash[:alert] = @order.pretty_base_errors
    end
    redirect_to order_path(@order) 
  end
  
  private

    def get_order
      @order = current_user.orders.find_by(invoice_number: params[:invoice_number])
      render_404 unless @order.present?
    end

    def get_current_users_open_orders
      @open_orders = current_user.orders.open.order(completed_at: :desc)
    end

    def get_current_users_delivered_orders
      @delivered_orders = current_user.orders.delivered.order(delivered_at: :desc)
    end

    def get_current_users_cancelled_orders
      @cancelled_orders = current_user.orders.cancelled.order(cancelled_at: :desc)
    end

end
