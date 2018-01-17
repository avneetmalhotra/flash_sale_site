class AddressesController < ApplicationController

  before_action :get_address, only: [:delivery_address]
  before_action :ensure_current_order_present
  before_action :update_current_order_state, only: [:new]

  def new
    @addresses = current_user.try(:addresses)
    @address = Address.new
  end

  def create
    @address = current_user.addresses.build(address_params)
    if @address.save
      current_order.address = @address
      current_order.save

      redirect_to new_payment_path, notice: I18n.t(:address_successfully_added, scope: [:flash, :notice])
    else
      @addresses = current_user.try(:addresses).where.not(id: nil)
      render 'new'
    end
  end

  def delivery_address
    current_order.address = @address
    current_order.save

    redirect_to new_payment_path, notice: I18n.t(:address_successfully_added, scope: [:flash, :notice])
  end

  private

    def address_params
      params.require(:address).permit(:house_number, :street, :city, :state, :country, :pincode )
    end

    def get_address
      @address = Address.find_by(id: params[:user][:last_used_address_id])
      render_404 unless @address.present?
    end

    def ensure_current_order_present
      if current_order.nil?
        redirect_to cart_url, alert: I18n.t(:cart_empty, scope: [:flash, :alert])
      end
    end

    def update_current_order_state
      if current_order.state?(:cart)
        unless current_order.add_address
          redirect_to cart_url, alert: current_order.base_errors
        end

      # if current_order.state?(:address)/(:payment) is true then:-
      else
        # check current_order's validity explicitly
        unless current_order.is_valid?
          redirect_to cart_url, alert: current_order.base_errors
        end
      end
    end

end
