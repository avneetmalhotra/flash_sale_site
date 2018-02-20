require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = User.find_by(id: 4)
    ##login
    post login_path, params: { user: { email: @user.email, password: 'password' } }
  end

  test 'should get index' do
    get admin_users_path
    assert_response :success
  end

  test 'should get new' do
    get new_admin_user_path
    assert_response :success
  end

  test 'should post create' do
    post admin_users_path, params: { user: { name: 'new_user', email: 'new_user@mail.com', 
        password: 'password', password_confirmation: 'password' } }
    assert_response :redirect
    assert_redirected_to admin_users_path
    assert_equal(I18n.t(:confirmation_email_sent, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not post create' do
    post admin_users_path, params: { user: { name: 'new_user', email: 'new_user@mail.com', 
        password: 'password', password_confirmation: 'wrong_password' } }
    assert_response :success
    assert_template 'new'
  end

  test 'should get show' do
    get admin_user_path(User.first)
    assert_response :success
  end

  test 'should not get show for invalid user' do
    get admin_user_path(00)
    assert_response :missing
    assert_template file: '404.html'
  end

  test 'should get edit' do
    get edit_admin_user_path(User.first)
    assert_response :success
  end

  test 'should not get edit for admin user' do
    get edit_admin_user_path(User.find_by(id: 4))
    assert_response :redirect
    assert_redirected_to admin_users_path
    assert_equal(I18n.t(:not_authorized, scope: [:flash, :alert]), flash[:alert])
  end

  test 'should patch update' do
    user = User.first
    patch admin_user_path(user), params: { user: { active: !user.active } }
    assert_response :redirect
    assert_redirected_to admin_users_path
    assert_equal(I18n.t(:customer_account_updated, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not patch update' do
    user = User.first
    patch admin_user_path(user), params: { user: { password: 'wrong_pass', password_confirmation: 'wrong_wrong_pass' } }
    assert_template 'edit'
  end

end
