class Payment < ApplicationRecord

  delegate :user, to: :order
  ## ASSOCIATIONS
  belongs_to :order

  ## SCOPES
  scope :successful, ->{ where(status: 'succeeded') }
  
  ## VALIDATIONS
  with_options presence: true do
    validates :currency, :status, :charge_id, :amount
  end

  validates :amount, numericality: { greater_than_or_equal_to: ENV['minimum_order_total_amount'].to_i }
  
  ## CALLBACKS
  after_commit :complete_order, if: :has_orders_payment_completed?  

  def create_stripe_record(stripe_token)
    create_stripe_customer(stripe_token)
    create_stripe_charge
    create_payment
  end

  private

    def create_stripe_customer(token)
      @customer = Stripe::Customer.create(email: user.email, source: token)
    end

    def create_stripe_charge
      @charge = Stripe::Charge.create(customer: @customer.id , amount: order.total_amount_in_cents.to_i, description: 'Flash Sale Customer', currency: 'usd')
    end

    def create_payment
      self.amount       =  order.total_amount
      self.charge_id    =  @charge.id
      self.currency     =  @charge.currency
      self.failure_code =  @charge.failure_code
      self.status       =  @charge.status
      save
    end

    def complete_order
      order.complete
    end

    def has_orders_payment_completed?
      order.total_amount <= order.payments.successful.sum(:amount)
    end

end
