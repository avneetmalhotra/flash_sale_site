class PaymentsController < ApplicationController

  before_action :ensure_current_order_present
  before_action :ensure_checkout_allowed
  before_action :update_current_order_state

  def new
  end

  private

    def update_current_order_state
      if current_order.cart?
        redirect_to cart_path, alert: I18n.t(:address_not_added, scope: [:flash, :alert])

      elsif current_order.can_pay?
        unless current_order.pay
          redirect_to cart_path, alert: current_order.pretty_base_errors
        end
      end
    end
end
