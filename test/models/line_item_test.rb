require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  
  test 'invalid without quantity, discount_price, price, loyalty_discount, total_amount' do
    line_item = LineItem.new deal_id: 1, order_id: 1
    line_item.valid?
    ## all these fields have predefined default values
    # assert_includes(line_item.errors[:quantity], "can't be blank")
    # assert_includes(line_item.errors[:discount_price], "can't be blank")
    # assert_includes(line_item.errors[:price], "can't be blank")
    # assert_includes(line_item.errors[:loyalty_discount], "can't be blank")
    # assert_includes(line_item.errors[:total_amount], "can't be blank")
  end

  test 'quantity must be an integer' do
    line_item = LineItem.new deal_id: 1, order_id: 1, quantity: 2.3
    line_item.valid?
    assert_includes(line_item.errors[:quantity], "must be an integer")
    assert_equal(line_item.pretty_errors, "Quantity must be an integer<br>This deal has expired.")
  end

  test 'quantity must be equal to the permitted value' do
    line_item = LineItem.new deal_id: 1, order_id: 1, quantity: 99
    line_item.valid?
    assert_includes(line_item.errors[:quantity], "must be equal to #{ENV['maximum_number_of_deals_one_can_order'].to_i}")
  end

  test 'invalid with price less than permitted minimum price' do
    line_item = LineItem.new deal_id: 1, order_id: 1, price: 0
    line_item.valid?
    assert_includes(line_item.errors[:price], "must be greater than or equal to #{ENV['minimum_price'].to_f}")
  end

  test 'invalid with discount price less than permitted minimum discount price' do
    line_item = LineItem.new deal_id: 1, order_id: 1, discount_price: 0
    line_item.valid?
    assert_includes(line_item.errors[:discount_price], "must be greater than or equal to #{ENV['minimum_discount_price'].to_f}")
  end

  test 'invalid with loyalty discount less than permitted minimum loyalty discount' do
    line_item = LineItem.new deal_id: 1, order_id: 1, loyalty_discount: -1
    line_item.valid?
    assert_includes(line_item.errors[:loyalty_discount], "must be greater than or equal to #{ENV['minimum_loyalty_discount'].to_i}")
  end

  test 'invalid if quantity more than available quantity' do
    line_item = LineItem.new deal_id: 3, order_id: 1, quantity: 10
    line_item.valid?
    assert_includes(line_item.errors[:quantity], I18n.t(:quantity_less_than_or_equal_to, scope: [:errors, :custom_validation], count: line_item.deal.quantity))
  end

  test 'invalid if associated deal already bought by the user before' do
    line_item = LineItem.new deal_id: 1, order_id: 2
    line_item.valid?
    assert_includes(line_item.errors[:base], I18n.t(:deal_already_bought, scope: [:errors, :custom_validation]))
  end

  test 'invalid if associated deal has expired' do
    line_item = LineItem.new deal_id: 1, order_id: 1
    line_item.valid?
    assert_includes(line_item.errors[:base], I18n.t(:deal_expired, scope: [:errors, :custom_validation]))
  end

  test 'if before save callbacks are working correctly' do
    line_item = LineItem.new deal_id: 2, order_id: 2, quantity: 1
    assert line_item.save
  end

end
