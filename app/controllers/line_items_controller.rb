class LineItemsController < ApplicationController
  before_action :get_deal, only: [:create]

  before_action :get_line_item, only: [:destroy]
  before_action :fetch_line_item, only: [:update]

  def create
    @line_item = current_order(create_new_order_if_nil: true).add_deal(@deal, params[:line_item][:quantity].to_i)

    if @line_item.save()
      redirect_to deal_url(@deal), notice: I18n.t(:deal_added_to_cart, scope: [:flash, :notice], deal_title: @deal.title)
    else
      redirect_to deal_url(@deal), alert: @line_item.pretty_error
    end
  end

  def destroy
    if @line_item.destroy
      redirect_to cart_url, notice: I18n.t(:deal_deleted_from_cart, scope: [:flash, :notice], deal_title: @line_item.deal.title)
    else
      redirect_to cart_url, alert: @line_item.pretty_error
    end
  end

  def update
    if @line_item.update(quantity: params[:new_quantity])
      render json: { success: true }
      flash[:notice] = I18n.t(:line_item_quantity_updated, scope: [:flash, :notice], deal_title: @line_item.deal.title)
    else
      render json: { success: false }
      flash[:alert] = @line_item.pretty_error
    end
  end

  private

    def get_deal
      @deal = Deal.find_by(id: params[:deal_id])
      redirect_to root_url, alert: I18n.t(:deal_cannot_be_added_to_cart, scope: [:flash, :alert]) unless @deal.present?
    end

    def get_line_item
      @line_item = LineItem.find_by(id: params[:id])
      redirect_to cart_url, alert: I18n.t(:line_item_cannot_be_deleted, scope: [:flash, :alert]) unless @line_item.present?
    end

    def fetch_line_item
      @line_item = LineItem.find_by(id: params[:line_item_id])
      redirect_to cart_url, alert: I18n.t(:line_item_cannot_be_updated, scope: [:flash, :alert]) unless @line_item.present?
    end
end
