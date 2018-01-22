class OrdersController < ApplicationController

  before_action :get_order, only: [:destroy]
  before_action :fetch_order, only: [:show]

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

  private

    def get_order
      @order = current_user.orders.find_by(id: params[:id])
      render_404 unless @order.present?
    end

    def fetch_order
      @order = current_user.orders.find_by(invoice_number: params[:invoice])
      render_404 unless @order.present?
    end

end
