require "test_helper"

class AddressesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = User.find_by(id: 4)
    ## login
    post login_path, params: { user: { email: @user.email, password: 'password' } }
    
    ## create order and line item
    deal = Deal.first
    deal.update_columns(end_at: 1.day.after)
    post line_items_path, params: { deal_id: deal.id, line_item: { quantity: 1 } }
  end

  test 'should get new' do
    get new_address_path
    assert_response :success
  end

  test 'should not get new is current order is empty' do
    User.find_by(id: 4).orders.delete_all    
    get new_address_path
    assert_response :redirect
    assert_redirected_to cart_path
    assert_equal(I18n.t(:cart_empty, scope: [:flash, :alert]), flash[:alert])
  end

  test 'should not get new due to checkout failure' do
    Deal.first.update_columns(end_at: 1.day.before)
    get new_address_path
    assert_response :redirect
    assert_redirected_to cart_path
    assert_equal(assigns(:current_order).pretty_errors, flash[:alert])
  end

  # test 'should not get new due to expired deal' do
  #   Deal.first.update_columns(end_at: 1.day.before)
  #   get new_address_path
  #   assert_response :redirect
  #   assert_redirected_to cart_path
  #   assert_equal(assigns(:current_order).pretty_errors, flash[:alert])
  # end

  test 'should post create' do
    post addresses_path, params: { address: { house_number: '23', street: '234', city: 'dfa', state: 'sdf', country: 'sdf', pincode: 1111 } }
    assert_response :redirect
    assert_redirected_to new_payment_path
    assert_equal(I18n.t(:address_successfully_added, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not post create successfully' do
    post addresses_path, params: { address: { house_number: '23', street: '234', city: 'dfa', state: 'sdf', country: 'sdf' } }
    assert_response :success
    assert_template 'new'    
  end

  test 'should patch associate address' do
    address = Address.second
    address.update_columns(user_id: 4)
    patch address_associate_address_path, params: { current_user: { recently_used_address_id: address.id } }
    assert_response :redirect
    assert_redirected_to new_payment_path
    assert_equal(I18n.t(:address_successfully_added, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not patch associate address due to invalid address' do
    patch address_associate_address_path, params: { current_user: { recently_used_address_id: 00 } }
    assert_response :missing
    assert_template file: '404.html'
  end

end
