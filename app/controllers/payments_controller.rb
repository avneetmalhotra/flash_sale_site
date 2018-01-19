class PaymentsController < ApplicationController
  before_action :ensure_current_order_present
  before_action :ensure_checkout_allowed
  before_action :update_current_order_state, only: [:new]

  def new
    @final_amount_in_cents = current_order.total_amount * 100
  end

  def create
    @final_amount = current_order.total_amount
    @final_amount_in_cents = @final_amount * 100

    begin
      payment = Stripe::Payment.create(
        customer_id:     current_user.id,
        amount:          @final_amount,
        order_id:        current_order.id
      )

    rescue Stripe::CardError => exception
      flash[:alert] = exception.message
      redirect_to new_payment_path
    end

    current_order.complete
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
