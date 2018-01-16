class LineItem < ApplicationRecord

  ## ASSOCIATINOS
  belongs_to :order
  belongs_to :deal

  ## VALIDATIONS
  # ensuring one quantity of a deal per order
  validates :quantity, numericality: { 
    only_integer: true,
    equal_to: ENV['maximum_number_of_deals_one_can_order'].to_i }
  
  # ensure quantity less than or equal to deal.quantity
  validate :ensure_quantity_available
 
  validate :ensure_deal_not_bought_again_in_another_order

  ## CALLBACKS
  before_save :update_loyalty_discount
  before_save :update_total_amount
  after_commit :update_orders_total, if: :order_not_deleted?

  def pretty_error
    errors.full_messages.join("<br>")
  end

  private

    def ensure_deal_not_bought_again_in_another_order
      associated_user = order.user
      if associated_user.line_items.where(deal_id: deal_id).where.not(order_id: order_id).present?
        errors[:base] << I18n.t(:deal_already_bought, scope: [:errors, :custom_validation])
      end
    end

    def ensure_quantity_available
      if quantity > deal.quantity
        errors[:quantity] << I18n.t(:quantity_less_than_or_equal_to, scope: [:errors, :custom_validation], count: deal.quantity)
      end
    end

    def update_loyalty_discount
      discount_percentage = LOYALTY_DISCOUNT_SLABS[order.user.orders.size.to_s]
      self.loyalty_discount = ((quantity.to_f * discount_price) / 100) * discount_percentage
    end

    def update_total_amount
      self.total_amount = quantity * discount_price - loyalty_discount
    end

    def order_not_deleted?
      Order.exists?(order.id)
    end
    
    def update_orders_total
      order.update(loyalty_discount: order.line_items.sum(:loyalty_discount), total_amount: order.line_items.sum(:total_amount))
    end

end
