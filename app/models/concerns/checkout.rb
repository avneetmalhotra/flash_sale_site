module Checkout

  extend ActiveSupport::Concern

  included do
    ## STATE MACHINE
    state_machine :state, initial: :cart do
      before_transition on: [:add_address, :pay, :complete], do: :checkout_allowed?
      after_transition on: :complete, do: [:set_completed_at, :decrease_deals_quantity, :send_confirmation_instructions]
      after_transition on: :deliver, do: :set_delivered_at
      before_transition on: :cancel, do: :cancellation_allowed?
      after_transition on: :cancel, do: [:set_cancelled_at, :restore_deals_quantity, :send_cancellation_instructions]

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

  def cancellation_allowed?
    are_deals_live? && can_be_cancelled?
  end

  private

    def set_completed_at
      update_columns(completed_at: Time.current)
    end

    def send_confirmation_instructions
      OrderMailer.confirmation_email(id).deliver_later
    end

    def set_delivered_at
      update_columns(deliverd_at: Time.current)
    end

    def set_cancelled_at
      update_columns(cancelled_at: Time.current)
    end

    def decrease_deals_quantity
      line_items.each do |line_item|
        deal = line_item.deal
        deal.update_columns(quantity: deal.quantity - line_item.quantity)
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
        if completed?
          errors[:base] << I18n.t(:has_expired_deals_cannot_be_cancelled, scope: [:order, :errors])
        else
          errors[:base] << I18n.t(:has_expired_deals_cannot_continue, scope: [:order, :errors])
        end
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
      if line_items.includes(:deal).all? { |line_item| line_item.deal.end_at - Time.current > ENV['minutes_before_expiration_when_deal_can_be_cancelled'].to_i.minutes }
        true
      else
        errors[:base] << I18n.t(:cannot_be_expired_x_minutes_before_deals_expiration, scope: [:order, :errors], x: ENV['minutes_before_expiration_when_deal_can_be_cancelled'])
        false       
      end
    end

    def restore_deals_quantity
      line_items.includes(:deal).each do |line_item|
        deal = line_item.deal
        deal.update_columns(quantity: deal.quantity + line_item.quantity)
      end
    end

    def send_cancellation_instructions
      OrderMailer.cancellation_email(id).deliver_later
    end

end
