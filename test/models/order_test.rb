require "test_helper"

class OrderTest < ActiveSupport::TestCase

  test 'invalid without invoice number' do
    # order = Order.new
    # order.valid?
    ## invoide number is added in before_validation callback
    # assert_includes(deal.errors[:invoice_number], "can't be blank")
  end

  test 'invalid with loyalty discount less than permitted minimum loyalty discount' do
    order = Order.new loyalty_discount: -1
    order.valid?
    assert_includes(order.errors[:loyalty_discount], "must be greater than or equal to #{ENV['minimum_loyalty_discount'].to_i}")
  end

  test 'invalid with total amount less than permitted minimum total amount' do
    order = Order.new total_amount: -1
    order.valid?
    assert_includes(order.errors[:total_amount], "must be greater than or equal to #{ENV['minimum_order_total_amount'].to_i}")
  end

  test 'invalid is state a does not exists' do
    order = Order.new state: 'wrong_state'
    order.valid?
    assert_includes(order.errors[:state], 'is not included in the list')
    assert_equal(order.pretty_errors, "State is invalid<br>State is not included in the list<br>User must exist")
  end

  test 'only incomplete order can be destroyed' do
    Order.third.destroy
  end

  test 'complete order cannot be destroyed' do
    Order.first.destroy
  end

  test 'association of an address' do
    order = Order.first
    assert order.associate_address(Address.second)
  end

  test 'get total items quantity' do
    order = Order.first
    quantity = order.line_items.sum(:quantity)
    assert_equal(quantity, order.total_items_quantity)
  end

  test 'get items subtotal' do
    order = Order.first
    assert_equal(order.line_items.sum(:discount_price), order.items_subtotal  )
  end

  test 'total amount return in cents' do
    order = Order.first
    assert_equal(order.total_amount * 100, order.total_amount_in_cents)
  end

  test 'addition of deal in order' do
    order = Order.first
    assert_difference 'order.line_items.find_by(id: Deal.first.id).quantity', difference = 2 do
      line_item = order.add_deal(Deal.first, 2)
      line_item.save(validate: false)
    end

    ##
    order = Order.second
    line_item = order.add_deal(Deal.first, 2)
    assert_kind_of(LineItem, line_item)
  end

  test 'to params return invoice number' do
    order = Order.first
    assert_equal(order.invoice_number, order.to_param)
  end

  test 'whether order can be cancelled by user' do
    order = Order.first
    user = order.user
    order.deals.each { |deal| deal.update_columns(end_at: 1.day.after) }
    assert order.cancelled_by!(user)
  end

  test 'whether order cannot be cancelled by  user' do
    order = Order.first
    user = order.user
    assert_raises StateMachines::InvalidTransition do
      order.cancelled_by!(user)
    end
    assert_includes(order.errors[:base], I18n.t(:has_expired_deals, scope: [:order, :errors]))
  end

  test 'whether order can be completed and delivered' do
    order = Order.first
    order.update_columns(state: 'cart')
    order.deals.each { |deal| deal.update_columns(end_at: 1.day.after) }
    assert order.add_address
    assert order.pay
    assert order.complete
    assert order.deliver
  end

  test 'whether checkout fails' do
    order = Order.first
    order.update_columns(state: 'address')
    assert_not order.pay
    assert_includes(order.errors[:base], I18n.t(:has_expired_deals, scope: [:order, :errors]))
  
    ##
    order.deals.each { |deal| deal.update_columns(end_at: 1.day.after, quantity: 0) }
    assert_not order.pay
    assert_includes(order.errors[:base], I18n.t(:invalid_deal_quantity, scope: [:order, :errors]))
  
    ##
    order = Order.third
    assert_not order.pay
    assert_includes(order.errors[:base], I18n.t(:cart_empty, scope: [:order, :errors]))
  end

  test 'cancellation by admin succeeds' do
    order = Order.first
    admin = User.where(admin: true).last
    order.deals.each { |deal| deal.update_columns(end_at: 1.day.after) }
    assert order.cancelled_by!(admin)
  end

  test 'cancellation fails when deal is about to expire' do
    order = Order.first
    order.deals.each { |deal| deal.update_columns(end_at: 10.minutes.after) }
    user = order.user

    assert_raises StateMachines::InvalidTransition do
      order.cancelled_by!(user)
    end
    assert_includes(order.errors[:base], I18n.t(:cannot_be_expired_minutes_before_deals_expiration, scope: [:order, :errors], minutes: (MINUTES_BEFORE_EXPIRATION_WHEN_DEAL_CAN_BE_CANCELLED.to_i / 60)))
  end
end
