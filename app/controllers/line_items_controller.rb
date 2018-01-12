class LineItemsController < ApplicationController
  before_action :get_cart, only: [:create]
  before_action :get_line_item, only: [:destroy]

  def create
    @deal = Deal.find_by(id: params[:deal_id])
    @line_item = @order.add_deal(params[:deal_id])

    if @line_item.save
      redirect_to deal_url(@deal), notice: I18n.t(:deal_added_to_cart, scope: [:flash, :notice], deal_title: @deal.title)
    else
      redirect_to deal_url(@deal), alert: @line_item.errors.full_messages.join("<br>")
    end
  end

  def destroy
    if @line_item.destroy
      redirect_to cart_url
    else
      redirect_to cart_url, alert: @line_item.errors.full_messages.join("<br>")
    end
  end

  private

    def get_cart
      if current_order.present?
        @order = current_order
      elsif current_user.orders.exists?(state: 'cart')
        @order = current_user.orders.where(state: 'cart').first
        session[:order_id] = @order.id
      else
        @order = current_user.orders.create
        session[:order_id] = @order.id
      end
    end

    def get_line_item
      @line_item = LineItem.find_by(id: params[:id])
    end
end
