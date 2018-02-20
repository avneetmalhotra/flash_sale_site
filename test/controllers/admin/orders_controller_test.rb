require "test_helper"

class Admin::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.find_by(id: 4)
    ##login
    post login_path, params: { user: { email: @user.email, password: 'password' } }
  end

  test 'should get index' do
    get admin_orders_path
    assert_response :success
  end

  test 'should get index on the basis of email' do
    get admin_orders_path, params: { search: { email: 'test' } }
    assert_response :success
  end

  test 'should get show' do
    order = Order.first
    get admin_order_path(order)
    assert_response :success
  end

  test 'should not ger show due to invalid order' do
    get admin_order_path('INV-invalid')
    assert_response :missing
    assert_template file: '404.html'
  end

  test 'should patch cancel' do
    order = Order.first
    patch cancel_admin_order_path(order)
    assert_response :redirect
    assert_redirected_to admin_order_path(order)
    assert_equal(I18n.t(:order_successfully_cancelled, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not patch cancel' do
    order = Order.third
    patch cancel_admin_order_path(order)
    assert_response :redirect
    assert_redirected_to admin_order_path(order)
    assert_equal("Cannot transition state via :admin_cancel from :address (Reason(s): State cannot transition via \"admin cancel\")", flash[:alert])
  end

  test 'should patch deliver' do
    order = Order.first
    patch deliver_admin_order_path(order)
    assert_response :redirect
    assert_redirected_to admin_order_path(order)
    assert_equal(I18n.t(:order_successfully_marked_delivered, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not patch deliver' do
    order = Order.third
    patch deliver_admin_order_path(order)
    assert_response :redirect
    assert_redirected_to admin_order_path(order)
    assert_equal(assigns(:order).pretty_errors, flash[:alert])
  end
end
