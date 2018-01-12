class Order < ApplicationRecord

  ## ASSOCIATIONS
  belongs_to :user
  has_many :line_items, dependent: :destroy

  ## CALLBACKS
  before_save :set_loyalty_discount, on: :create

  ## STATE MACHINE
  state_machine :state, initial: :cart do
    event :add_address do
      transition cart: :address
    end

    event :checkout do
      transition address: :payment
    end

    state :cart do
      def add_deal(deal_id)
        deal = Deal.find_by(id: deal_id)
        line_items.build(deal_id: deal_id, price: deal.price, discount_price: deal.discount_price)
      end

      def total_amount
      amount = 0
      if line_items.exists?
        line_items.each do |line_item|
          amount += line_item.discount_price * line_item.quantity
        end
      end
      amount
      end

    end
  end

  private

    def set_loyalty_discount
      user = User.find_by(id: user_id)
      self.loyalty_discount = LOYALTY_DISCOUNT_SLABS[user.orders.size.to_s]
    end

end 
