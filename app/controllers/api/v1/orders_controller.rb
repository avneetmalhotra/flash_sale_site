class Api::V1::OrdersController < Api::V1::BaseController
  
  before_action :get_user

  def index
    @orders = @user.orders.includes(:address, :line_items, :payments)

    render json: @orders
  end

  private

    def get_user
      @user = User.find_by(api_token: params[:token])

      if @user.nil?
        render json: { error: I18n.t(:not_authorized, scope: :api)}, status: 401 and return
      end

    end
end
