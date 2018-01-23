class PaymentsController < ApplicationController
  before_action :ensure_current_order_present
  before_action :ensure_checkout_allowed, only: [:new, :create]
  before_action :update_current_order_state, only: [:new, :create]

  def new
  end

  def create
    @payment = current_order.payments.build
    create_stripe_payment!
    redirect_to order_path(@payment.order)
  end


  private

    def update_current_order_state
      if current_order.cart?
        redirect_to cart_path, alert: I18n.t(:address_not_added, scope: [:flash, :alert]) and return

      elsif current_order.can_pay?
        unless current_order.pay
          redirect_to cart_path, alert: current_order.pretty_base_errors and return
        end
      end
    end

    def create_stripe_payment!
      begin
        @payment.create_stripe_record(params[:stripeToken])
      rescue Stripe::CardError => exception
        redirect_to new_payment_path, alert: I18n.t(:invalid_card, scope: [:flash, :alert]) and return
      rescue Stripe::RateLimitError, Stripe::InvalidRequestError, Stripe::AuthenticationError, Stripe::APIConnectionError => exception
        redirect_to new_payment_path, alert: I18n.t(:incomplete_transaction, scope: [:flash, :alert]) and return
      rescue Stripe::StripeError => exception
        redirect_to new_payment_path, alert: exception.message and return
      end
    end

end
