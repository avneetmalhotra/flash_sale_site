require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = User.find_by(id: 4)
    ## login
    post login_path, params: { user: { email: @user.email, password: 'password' } }
    
    ## create order and line item
    deal = Deal.first
    deal.update_columns(end_at: 1.day.after)
    post line_items_path, params: { deal_id: deal.id, line_item: { quantity: 1 } }

    ## associate address
    address = Address.second
    address.update_columns(user_id: 4)
    patch address_associate_address_path, params: { current_user: { recently_used_address_id: address.id } }
  end

  test 'should get new' do
    get new_payment_path
    assert_response :success
  end

  test 'should not get new if current order state is cart' do
    assigns(:current_order).update_columns(state: 'cart')
    get new_payment_path
    assert_response :redirect
    assert_redirected_to cart_path
    assert_equal(I18n.t(:address_not_added, scope: [:flash, :alert]), flash[:alert])
  end

  # test 'should post create' do
  #   post payments_path
  #   assert_response :redirect
  #   assert_redirected_to order_path(assigns(:payment).order)
  #   assert_equal(I18n.t(:order_placed_successfully, scope: [:flash, :notice]), flash[:notice])
  # end
end
