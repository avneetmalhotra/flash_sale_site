class PaymentsController < ApplicationController

  before_action :ensure_current_order_present
  before_action :update_current_order_state

  def new
  end

  private

    def ensure_current_order_present
      if current_order.nil?
        redirect_to cart_url, alert: I18n.t(:cart_empty, scope: [:flash, :alert])
      end
    end

    def update_current_order_state
      if current_order.state?(:cart)
        redirect_to cart_url, alert: I18n.t(:address_not_added, scope: [:flash, :alert])

      elsif current_order.state?(:address)
        unless current_order.checkout
          redirect_to cart_url, alert: current_order.base_errors
        end

      # if current_order.state?(:payment) is true then:-
      else 
        # check current_order's validity explicitly
        unless current_order.is_valid?
          redirect_to cart_url, alert: current_order.base_errors
        end
      end
    end
end
