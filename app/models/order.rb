class Order < ApplicationRecord

  ## ASSOCIATIONS
  belongs_to :user
  has_many :line_items, dependent: :destroy
  belongs_to :address, optional: true

  ## SCOPES
  scope :incomplete, ->{ where(completed_at: nil) }

  ## CALLBACKS
  before_destroy :ensure_order_incomplete

  ## STATE MACHINE
  state_machine :state, initial: :cart do
    event :add_address do
      transition cart: :address, if: :is_valid?
    end

    event :checkout do
      transition address: :payment, if: :is_valid?
    end

  end

  def pretty_errors
    errors.full_messages.join("<br>")
  end

  def base_errors
    errors[:base].join("<br>")
  end

  def is_valid?
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

  private

    def ensure_order_incomplete
      if completed_at.present?
        errors[:base] << I18n.t(:order_cannot_be_deleted, scope: [:flash, :alert])
        throw :abort
      end    
    end


    def is_order_not_empty?
      unless line_items.exists?
        errors[:base] << I18n.t(:cart_empty, scope: [:order, :errors])
        return false
      end
      true
    end

    def are_deals_live?
      line_items.includes(:deal).each do |line_item|
        if line_item.deal.is_expired?
          errors[:base] << I18n.t(:has_expired_deals, scope: [:order, :errors])
          return false
        end
      end
      true
    end

    def are_deals_quantity_valid?
      line_items.each do |line_item|
        if line_item.deal.quantity < line_item.quantity
          errors[:base] << I18n.t(:has_invalid_deal_quantity, scope: [:order, :errors], deal_title: line_item.deal.title)
          return false
        end
      end
      true
    end

end 
