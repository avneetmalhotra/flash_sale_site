require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  test 'invalid without currency, status, charge_id, amount' do
    payment = Payment.new
    payment.valid?
    assert_includes(payment.errors[:currency], "can't be blank")
    assert_includes(payment.errors[:status], "can't be blank")
    assert_includes(payment.errors[:charge_id], "can't be blank")
    assert_includes(payment.errors[:amount], "can't be blank")
  end

  test 'invalid with amount less than permitted minimum order total amount' do
    payment = Payment.new amount: -1
    payment.valid?
    assert_includes(payment.errors[:amount], "must be greater than or equal to #{ENV['minimum_order_total_amount'].to_i}")
  end

end
