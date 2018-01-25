class Api::V1::OrdersController < Api::V1::BaseController
  
  before_action :get_orders

  def index
    if @orders.empty?
      render json: I18n.t(:user_does_not_has_any_order, scope: [:api, :order])
    else
      render json: @orders
    end
  end

  private

    def get_orders
      user = User.find_by(api_token: params[:token])
      
      if user.nil?
        render json: I18n.t(:invalid_user, scope: [:api, :order]) and return
      end

      @orders = user.orders.includes(:address, line_items: :deal)
    end
end
