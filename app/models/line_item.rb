class LineItem < ApplicationRecord

  ## ASSOCIATINOS
  belongs_to :order
  belongs_to :deal

  ## VALIDATIONS
  # ensuring one quanitity of a deal per order
  validates :deal_id, uniqueness: { scope: :order_id, message: I18n.t(:can_be_bought_once, scope: [:errors, :custom_validation]) }
  validate :ensure_deal_not_bought_again_in_another_order

  private

    def ensure_deal_not_bought_again_in_another_order
      associated_user = order.user
      if associated_user.line_items.exists?(deal_id: deal_id) && !order.line_items.exists?(deal_id: deal_id)
        errors[:base] << I18n.t(:deal_already_bought, scope: [:errors, :custom_validation])
      end
    end
end
