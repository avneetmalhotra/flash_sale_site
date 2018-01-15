class OrdersController < ApplicationController

  before_action :get_order, only: [:destroy]

  def cart
  end

  def destroy
    if @order.destroy
      redirect_to root_url, notice: I18n.t(:cart_emptied, scope: [:flash, :notice])
    else
      flash.now[:alert] = @order.pretty_error
      render :edit
    end
  end
  
  private

    def get_order
      @order = current_order
      render_404 unless @order.present?
    end

end
