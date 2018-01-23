class Order < ApplicationRecord
  include TokenGenerator
  include Checkout

  ## ASSOCIATIONS
  belongs_to :user
  has_many :line_items, dependent: :destroy
  has_many :deals, through: :line_items
  belongs_to :address, optional: true
  has_many :payments, dependent: :destroy

  ## VALIDATIONS
  validates :invoice_number, presence: true,  uniqueness: { allow_blank: true }
  validates :loyalty_discount, allow_blank: true, numericality: { greater_than_or_equal_to: ENV['minimum_loyalty_discount'].to_i }
  validates :total_amount, allow_blank: true, numericality: { greater_than_or_equal_to: ENV['minimum_order_total_amount'].to_i }

  ## SCOPES
  scope :incomplete, ->{ where(completed_at: nil) }
  scope :complete, ->{ where.not(completed_at: nil) }

  ## CALLBACKS
  before_destroy :ensure_order_incomplete
  before_validation :generate_invoice_number, on: :create


  def pretty_errors
    errors.full_messages.join("<br>")
  end

  def pretty_base_errors
    errors[:base].join("<br>")
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

  def total_items_quantity
    line_items.sum(:quantity)
  end

  def total_amount_in_cents
    total_amount * 100
  end

  def to_param
    invoice_number
  end

  private

    def ensure_order_incomplete
      if completed_at.present?
        errors[:base] << I18n.t(:order_cannot_be_deleted, scope: [:flash, :alert])
        throw :abort
      end    
    end

    def generate_invoice_number
      self.invoice_number = generate_unique_token(:invoice_number, 8, 'INV-')
    end
end 
