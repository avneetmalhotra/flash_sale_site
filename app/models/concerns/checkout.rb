module Checkout

  extend ActiveSupport::Concern

# STATES:-
# cart    -> order in cart
# address -> order's address has been added
# payment -> order's payment has started
# completed -> order has been successfully placed
## flow - cart -> address -> payment -> completed

  included do
    ## STATE MACHINE
    state_machine :state, initial: :cart do
      before_transition on: [:add_address, :pay, :complete], do: :checkout_allowed?
      after_transition on: :complete, do: [:set_completed_at, :decrease_deals_stock, :send_confirmation_instructions]

      event :add_address do
        transition cart: :address
      end

      event :pay do
        transition address: :payment
      end

      event :complete do
        transition payment: :completed
      end

    end
  end

  def checkout_allowed?
    is_order_not_empty? && are_deals_live? && are_deals_quantity_valid?
  end

  private

    def set_completed_at
      update(completed_at: Time.current)
    end

    def send_confirmation_instructions
      OrderMailer.confirmation_email(id).deliver_later
    end

    def decrease_deals_stock
      line_items.includes(:deal).each do |line_item|
        deal = line_item.deal
        deal.update_columns(quantity: deal.quantity - line_item.quantity)
      end
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

end
