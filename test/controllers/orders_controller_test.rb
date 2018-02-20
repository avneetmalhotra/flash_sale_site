require 'test_helper'

class OrdersControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = User.find_by(id: 4)
    ##login
    post login_path, params: { user: { email: @user.email, password: 'password' } }
  end

  test 'should get cart' do
    get cart_path
    assert_response :success
  end

  test 'should destroy order' do
    order = Order.third
    order.update_columns(user_id: 4)
    delete order_path(order)
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal(I18n.t(:cart_emptied, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not destroy order due to invalis order' do
    order = Order.third
    delete order_path(order)
    assert_response :missing
    assert_template file: '404.html'
  end

  test 'should not destroy complete order' do
    order = Order.first
    order.update_columns(user_id: 4)
    delete order_path(order)
    assert_response :redirect
    assert_redirected_to cart_path
    assert_equal(assigns[:order].pretty_errors, flash[:alert])
  end

  test 'should get index' do
    get orders_path
    assert_response :success
  end

  test 'should cancel order' do
    order = Order.first
    order.update_columns(user_id: 4)
    patch cancel_order_path(order)
    assert_response :redirect
    assert_redirected_to order_path(order)
    assert_equal(I18n.t(:order_successfully_cancelled, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not cancel order' do
    order = Order.third
    order.update_columns(user_id: 4)
    patch cancel_order_path(order)
    assert_response :redirect
    assert_redirected_to order_path(order)
    assert_equal("Cannot transition state via :admin_cancel from :address (Reason(s): State cannot transition via \"admin cancel\")", flash[:alert])
  end
end
