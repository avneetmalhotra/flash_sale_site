require "test_helper"

class AddressTest < ActiveSupport::TestCase

  test 'invalid without house_number, street, city, state, country, pincode' do
    address = Address.new
    address.valid?
    assert_includes(address.errors[:house_number], "can't be blank")
    assert_includes(address.errors[:street], "can't be blank")
    assert_includes(address.errors[:city], "can't be blank")
    assert_includes(address.errors[:state], "can't be blank")
    assert_includes(address.errors[:country], "can't be blank")
    assert_includes(address.errors[:pincode], "can't be blank")
    assert_equal(address.pretty_errors, "User must exist<br>House number can't be blank<br>Street can't be blank<br>City can't be blank<br>State can't be blank<br>Country can't be blank<br>Pincode can't be blank")
  end

  test 'invalid with pincode less than 0' do
    address = Address.new pincode: -34
    address.valid?
    assert_includes(address.errors[:pincode], "must be greater than 0")
  end

  test 'invalid with non-integer pincode' do
    address = Address.new pincode: 3.4
    address.valid?
    assert_includes(address.errors[:pincode], "must be an integer")
  end

  test 'invalid with duplicate address' do
    address = Address.new(house_number: '23d', street: 'patel Nagar', city: 'Delhi', pincode: 111111)
    address.valid?
    assert_includes(address.errors[:house_number], 'has already been taken')
  end

  test 'full address returned' do
    address = Address.first
    full_address = "#{address.house_number}<br>#{address.street}<br>#{address.city}, #{address.state} - #{address.pincode}<br>#{address.country}"
    assert_equal(full_address, address.full_address)
  end
end
