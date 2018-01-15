class Order < ApplicationRecord

  ## ASSOCIATIONS
  belongs_to :user
  has_many :line_items, dependent: :destroy

  ## STATE MACHINE
  state_machine :state, initial: :cart do
    event :add_address do
      transition cart: :address
    end

    event :checkout do
      transition address: :payment
    end

    state :cart do
      def add_deal(deal, line_item_quantity)
        line_item_temp = line_items.find_by(deal_id: deal.id)
        if line_item_temp.present?
          line_item_temp.quantity += line_item_quantity
        else
          line_item_temp = line_items.build(deal_id: deal.id, price: deal.price, discount_price: deal.discount_price, quantity: line_item_quantity)
        end
        line_item_temp
      end

    end
  end

  def pretty_error
    errors.full_messages.join("<br>")
  end

end 
