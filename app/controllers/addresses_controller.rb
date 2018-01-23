class AddressesController < ApplicationController

  before_action :ensure_current_order_present
  before_action :ensure_checkout_allowed
  before_action :update_current_order_state, only: [:new]
  before_action :get_current_user_associated_addresses, only: [:new, :create]
  before_action :get_address, only: [:associate_address]

  def new
    @address = Address.new
  end

  def create
    @address = current_user.addresses.build(address_params)
    @addresses.reload

    if @address.save
      if current_order.associate_address(@address)
        redirect_to new_payment_path, notice: I18n.t(:address_successfully_added, scope: [:flash, :notice]) and return
      else
        redirect_to new_address_path, alert: current_order.pretty_errors and return
      end
    else
      render 'new'
    end
  end

  def associate_address
    if current_order.associate_address(@address)
      redirect_to new_payment_path, notice: I18n.t(:address_successfully_added, scope: [:flash, :notice])
    else
      redirect_to new_address_path, alert: current_order.pretty_errors
    end
  end

  private

    def address_params
      params.require(:address).permit(:house_number, :street, :city, :state, :country, :pincode)
    end

    def get_address
      @address = Address.find_by(id: params[:current_user][:recently_used_address_id])
      render_404 unless @address.present?
    end

    def update_current_order_state
      if current_order.can_add_address?
        unless current_order.add_address
          redirect_to cart_path, alert: current_order.pretty_base_errors and return
        end
      end
    end

    def get_current_user_associated_addresses
      @addresses = current_user.addresses
    end

end
