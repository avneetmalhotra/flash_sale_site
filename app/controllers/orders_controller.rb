class OrdersController < ApplicationController

  before_action :get_order, only: [:destroy]

  def cart
  end

  def destroy
    if @order.destroy
      session[:order_id] = nil
      redirect_to root_url, notice: I18n.t(:cart_emptied, scope: [:flash, :notice])
    else
      flash.now[:alert] = @order.errors.full_messages.join("<br>")
      render :edit
    end
  end
  
  private

    def get_order
      @order = Order.find_by(id: params[:id])
    end

end
