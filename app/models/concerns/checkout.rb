module Checkout

  extend ActiveSupport::Concern

# STATES:-
# cart    -> order in cart
# address -> order's address can been added now
# payment -> order's payment has started
# completed -> order has been successfully placed
# cancelled -> order has been cancelled
# delivered -> order has been delivered
## flow - cart -> address -> payment -> completed -> (cancelled or delivered)

  included do
    ## STATE MACHINE
    state_machine :state, initial: :cart do
      before_transition on: [:add_address, :pay, :complete], do: :ensure_checkout_allowed?
      after_transition on: :complete, do: [:set_completed_at, :decrease_deals_stock, :send_confirmation_email]
      after_transition on: :deliver, do: [:set_delivered_at, :send_delivery_email]
      
      after_transition completed: :cancelled, do: [:set_cancelled_at, :increase_deals_stock]
      after_transition on: :cancel, do: [:send_cancellation_email]
      after_transition on: :admin_cancel, do: [:send_admin_cancellation_email]


      event :add_address do
        transition cart: :address
      end

      event :pay do
        transition address: :payment
      end

      event :complete do
        transition payment: :completed
      end

      event :cancel do
        transition completed: :cancelled, if: :cancellation_allowed?
      end

      event :admin_cancel do
        transition completed: :cancelled
      end

      event :deliver do
        transition completed: :delivered
      end

    end
  end

  def checkout_allowed?
    is_order_not_empty? && are_deals_live? && are_deals_quantity_valid?
  end

  def cancelled_by!(canceller)
    if canceller.admin?
      admin_cancel!
    else
      cancel!
    end
    update_columns(canceller_id: canceller.id)
  end


  private

    def ensure_checkout_allowed?
      checkout_allowed?
    end
 
    def cancellation_allowed?
      are_deals_live? && can_be_cancelled?
    end

    def set_completed_at
      update_columns(completed_at: Time.current)
    end

    def send_confirmation_email
      OrderMailer.confirmation_email(id).deliver_later
    end

    def decrease_deals_stock
      line_items.includes(:deal).each do |line_item|
        deal = line_item.deal
        deal.update_columns(quantity: deal.quantity - line_item.quantity)
      end
    end

    def set_delivered_at
      update_columns(delivered_at: Time.current)
    end

    def set_cancelled_at
      update_columns(cancelled_at: Time.current)
    end

    def increase_deals_stock
      line_items.includes(:deal).each do |line_item|
        deal = line_item.deal
        deal.update_columns(quantity: deal.quantity + line_item.quantity)
      end
    end

    def is_order_not_empty?
      if line_items.empty?
        errors[:base] << I18n.t(:cart_empty, scope: [:order, :errors])
        false
      else 
        true
      end
    end

    def are_deals_live?
      if deals.expired.present?
        errors[:base] << I18n.t(:has_expired_deals, scope: [:order, :errors])
        false
      else
        true
      end
    end

    def are_deals_quantity_valid?
      if line_items.includes(:deal).all? { |line_item| line_item.deal.quantity >= line_item.quantity }
        true
      else
        errors[:base] << I18n.t(:invalid_deal_quantity, scope: [:order, :errors])
        false
      end
    end

    def can_be_cancelled?
      # check if deal can be cancelled x minutes before deal expires
      if deals.where('end_at > ?',Time.current + MINUTES_BEFORE_EXPIRATION_WHEN_DEAL_CAN_BE_CANCELLED ).present?
        true
      else
        errors[:base] << I18n.t(:cannot_be_expired_minutes_before_deals_expiration, scope: [:order, :errors], minutes: (MINUTES_BEFORE_EXPIRATION_WHEN_DEAL_CAN_BE_CANCELLED.to_i / 60))
        false       
      end
    end

    def send_cancellation_email
      OrderMailer.cancellation_email(id).deliver_later
    end

    def send_delivery_email
      OrderMailer.delivery_email(id).deliver_later
    end

    def send_admin_cancellation_email
      OrderMailer.cancellation_by_admin_email(id).deliver_later
    end

end
