class Payment < ApplicationRecord

  ## ASSOCIATIONS
  belongs_to :order
  
  ## VALIDATIONS
  with_options presence: true do
    validates :currency, :status, :charge_id, :amount, :user_id
  end

  validates :user_id, numericality: {
    only_integer: true,
    greater_than: 0
  }

  validates :amount, numericality: { greater_than_or_equal_to: ENV['minimum_order_total_amount'].to_i }
    

  def create_stripe_record(stripe_token)
    create_stripe_customer(stripe_token)
    create_stripe_charge
    create_payment
  end

  private

    def create_stripe_customer(token)
      @customer = Stripe::Customer.create(email: order.user.email, source: token)
    end

    def create_stripe_charge
      @charge = Stripe::Charge.create(customer: @customer.id , amount: order.total_amount_in_cents.to_i, description: 'Flash Sale Customer', currency: 'usd')
    end

    def create_payment
      update(charge_id: @charge.id, currency: @charge.currency, failure_code: @charge.failure_code, status: @charge.status)
    end

end
