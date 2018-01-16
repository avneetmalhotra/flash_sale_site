class LineItemsController < ApplicationController
  before_action :get_deal, only: [:create]
  before_action :get_line_item, only: [:destroy, :update]

  def create
    @line_item = current_order(options = {create_new_order: true}).add_deal(@deal, params[:line_item][:quantity].to_i)

    if @line_item.errors.present?
      redirect_to deal_path(@deal), alert: @line_item.pretty_error
    else
      redirect_to cart_path, notice: I18n.t(:deal_added_to_cart, scope: [:flash, :notice], deal_title: @deal.title)
    end
  end

  def destroy
    if @line_item.destroy
      flash[:notice] = I18n.t(:deal_deleted_from_cart, scope: [:flash, :notice], deal_title: @line_item.deal.title)
    else
      flash[:alert] = @line_item.pretty_error
    end
    redirect_to cart_path
  end

  def update
    if @line_item.update(update_params)
      flash[:notice] = I18n.t(:line_item_quantity_updated, scope: [:flash, :notice], deal_title: @line_item.deal.title)
    else
      flash[:alert] = @line_item.pretty_error
    end
    redirect_to cart_path
  end

  private

    def get_deal
      @deal = Deal.find_by(id: params[:deal_id])
      redirect_to root_path, alert: I18n.t(:deal_cannot_be_added_to_cart, scope: [:flash, :alert]) unless @deal.present?
    end

    def get_line_item
      @line_item = LineItem.find_by(id: params[:id])
      render_404 unless @line_item.present?
    end

    def update_params
      params.require(:line_item).permit(:quantity)
    end

end
