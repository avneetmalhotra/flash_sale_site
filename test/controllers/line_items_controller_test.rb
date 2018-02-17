require "test_helper"

class LineItemsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = User.find_by(id: 4)
    ##login
    post login_path, params: { user: { email: @user.email, password: 'password' } }
  end

  test 'should post create' do
    deal = Deal.first
    deal.update_columns(end_at: 1.day.after)
    post line_items_path, params: { deal_id: deal.id, line_item: { quantity: 1 } }
    assert_response :redirect
    assert_redirected_to cart_path
    assert_equal(I18n.t(:deal_added_to_cart, scope: [:flash, :notice], deal_title: deal.title), flash[:notice])
  end

  test 'should not post create due to expired deal' do
    deal = Deal.first
    post line_items_path, params: { deal_id: deal.id, line_item: { quantity: 1 } }
    assert_response :redirect
    assert_redirected_to deal_path(deal)
    assert_equal(assigns(:line_item).pretty_errors, flash[:alert])
  end

  test 'should not post create due to invalid deal' do
    post line_items_path, params: { deal_id: 00, line_item: { quantity: 1 } }
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal(I18n.t(:deal_cannot_be_added_to_cart, scope: [:flash, :alert]), flash[:alert])
  end

  test 'should destroy line_item' do
    order = Order.first
    order.line_items.first.deal.update_columns(end_at: 1.day.after)
    line_item = order.line_items.first
    delete line_item_path(line_item)
    assert_response :redirect
    assert_redirected_to cart_path
    assert_equal(I18n.t(:deal_deleted_from_cart, scope: [:flash, :notice], deal_title: line_item.deal.title), flash[:notice])
  end

  test 'should not destroy line_item due to invalid line_item' do
    delete line_item_path(00)
    assert_response :missing
    assert_template file: '404.html'
  end

  ## any line_item can be destroyed without any issue
  # test 'should not destroy line_item' do
  #   order = Order.first
  #   line_item = order.line_items.first
  #   delete line_item_path(line_item)
  #   assert_response :redirect
  #   assert_redirected_to cart_path
  #   assert_equal(assigns(:line_item), flash[:alert])
  # end

  test 'should update line_item' do
    order = Order.first
    order.line_items.first.deal.update_columns(end_at: 1.day.after)
    line_item = order.line_items.first
    patch line_item_path(line_item), params: { line_item: { quantity: 1 } }
    assert_response :redirect
    assert_redirected_to cart_path
    assert_equal(I18n.t(:line_item_quantity_updated, scope: [:flash, :notice], deal_title: line_item.deal.title), flash[:notice])
  end

  test 'should not update line_item' do
    order = Order.first
    order.line_items.first.deal.update_columns(end_at: 1.day.after)
    line_item = order.line_items.first
    patch line_item_path(line_item), params: { line_item: { quantity: 10 } }
    assert_response :redirect
    assert_redirected_to cart_path
    assert_equal(assigns(:line_item).pretty_errors, flash[:alert])
  end
end
