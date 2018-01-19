class Order < ApplicationRecord

  ## ASSOCIATIONS
  belongs_to :user
  has_many :line_items, dependent: :destroy
  belongs_to :address, optional: true
  has_many :deals, through: :line_items

  ## SCOPES
  scope :incomplete, ->{ where(completed_at: nil) }
  scope :complete, ->{ where.not(completed_at: nil) }

  ## CALLBACKS
  before_destroy :ensure_order_incomplete

  ## STATE MACHINE
  state_machine :state, initial: :cart do
    before_transition on: [:add_address, :pay], do: :checkout_allowed?

    event :add_address do
      transition cart: :address
    end

    event :pay do
      transition address: :payment
    end

  end

  def pretty_errors
    errors.full_messages.join("<br>")
  end

  def pretty_base_errors
    errors[:base].join("<br>")
  end

  def checkout_allowed?
    is_order_not_empty? && are_deals_live? && are_deals_quantity_valid?
  end

  def add_deal(deal, line_item_quantity = 1)
    line_item_temp = line_items.find_by(deal_id: deal.id)
    if line_item_temp.present?
      line_item_temp.quantity += line_item_quantity
      line_item_temp.save
    else
      line_item_temp = line_items.create(deal_id: deal.id, price: deal.price, discount_price: deal.discount_price, quantity: line_item_quantity)
    end
    line_item_temp
  end

  def associate_address(address)
    update(address: address)
  end

  private

    def ensure_order_incomplete
      if completed_at.present?
        errors[:base] << I18n.t(:order_cannot_be_deleted, scope: [:flash, :alert])
        throw :abort
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
