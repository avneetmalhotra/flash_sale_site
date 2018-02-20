require "test_helper"

class Admin::DealsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = User.find_by(id: 4)
    ##login
    post login_path, params: { user: { email: @user.email, password: 'password' } }
  end

  test 'should get index' do
    get admin_deals_path
    assert_response :success
  end

  test 'should get new' do
    get new_admin_deal_path
    assert_response :success
  end

  test 'should create deal' do
    assert_difference 'Deal.count' do
      post admin_deals_path, params: { deal: { title: 'deal9', description: 'afafa', price: 234, 
        discount_price: 22.3, quantity: 8 } }
    end
    assert_response :redirect
    assert_redirected_to admin_deals_path
    assert_equal(I18n.t(:deal_created, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not create deal' do
    assert_no_difference 'Deal.count' do
      post admin_deals_path, params: { deal: { title: 'deal9', description: 'afafa', price: 234, 
        discount_price: 22.3, quantity: 2, publishing_date: Date.current } }
    end
    assert_response :success
    assert_template 'new'
  end

  test 'should get edit deal' do
    get edit_admin_deal_path(Deal.first)
    assert_response :success
  end

  test 'should not get edit deal' do
    get edit_admin_deal_path(99)
    assert_response :missing
    assert_template file: '404.html'
  end

  test 'should update deal' do
    deal = Deal.second
    deal.update_columns(publishing_date: 3.days.after, start_at: nil, end_at: nil)
    patch admin_deal_path(deal), params: { deal: { title: 'new_deal_title' } }
    deal.reload
    assert_equal('new_deal_title', deal.title)
    assert_response :redirect
    assert_redirected_to admin_deals_path
    assert_equal(I18n.t(:deal_updated, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not update deal' do
    deal = Deal.first
    patch admin_deal_path(deal), params: { deal: { title: 'new_deal_title' } }
    assert_template 'edit'
    assert_response :success
    deal.reload
    assert_not_equal('new_deal_title', deal.title)    
  end

  test 'should destroy' do
    deal = Deal.second
    deal.update_columns(publishing_date: 3.days.after, start_at: nil, end_at: nil)
    assert_difference 'Deal.count', difference = -1 do
      delete admin_deal_path(deal)
    end
    assert_response :redirect
    assert_redirected_to admin_deals_path
    assert_equal(I18n.t(:deal_successfully_destroyed, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not destroy' do
    deal = Deal.second
    deal.update_columns(publishing_date: Date.current, start_at: Time.current, end_at: 1.day.after)
    assert_no_difference 'Deal.count' do
      delete admin_deal_path(deal)
    end
    assert_response :redirect
    assert_redirected_to admin_deals_path
    assert_equal(assigns(:deal).pretty_errors, flash[:alert])
  end
end
