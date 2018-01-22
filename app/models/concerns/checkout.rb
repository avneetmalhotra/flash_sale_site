module Checkout

  extend ActiveSupport::Concern

  included do
    ## STATE MACHINE
    state_machine :state, initial: :cart do
      before_transition on: [:add_address, :pay, :complete], do: :checkout_allowed?
      after_transition on: :complete, do: [:set_completed_at, :update_deals_quantity, :send_confirmation_instructions]

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

    def update_deals_quantity
      line_items.each do |line_item|
        line_item.deal.quantity -= line_item.quantity
      end
    end

    def rollback_deal_quantity_update
      line_items.each do |line_item|
        line_item.deal.quantity += line_item.quantity
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
