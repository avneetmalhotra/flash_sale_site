require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest

  test 'should get new' do
    get login_path
    assert_response :success
  end

  test 'should create session for user' do
    user = User.first
    post login_path, params: { user: { email: user.email, password: 'password' }, remember_me: 'yes' }
    assert_redirected_to root_path
    ## cannot test encrypted/signed cookies
    # assert_equal(user.remember_me_token, cookies.encrypted[:remember_me])
    assert_equal(user.id, session[:user_id])
    assert_equal(I18n.t(:login_successfull, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should create session for admin' do
    user = User.find_by(id: 4)
    post login_path, params: { user: { email: user.email, password: 'password' } }
    assert_redirected_to admin_deals_path
    assert_equal(user.id, session[:user_id])
    assert_equal(I18n.t(:login_successfull, scope: [:flash, :notice]), flash[:notice])
  end

  test 'session creation fails due to invalid user' do
    post login_path, params: { user: { email: 'invalid@mail.com', password: 'password' } }
    assert_redirected_to login_path
    assert_equal(I18n.t(:invalid_email_or_password, scope: [:flash, :alert]), flash[:alert])
  end

  test 'session creation fails due unconfirmed user' do
    user = User.find_by(id: 6)
    post login_path, params: { user: { email: user.email, password: 'password' } }
    assert_redirected_to login_path
    assert_equal(I18n.t(:account_not_confirmed, scope: [:flash, :alert]), flash[:alert])
  end

  test 'session creation fails due to inactive user' do
    user = User.find_by(id: 7)
    post login_path, params: { user: { email: user.email, password: 'password' } }
    assert_redirected_to login_path
    assert_equal(I18n.t(:account_inactive, scope: [:flash, :alert]), flash[:alert])
  end

  test 'session creation fails due to wrong password' do
    user = User.first
    post login_path, params: { user: { email: user.email, password: 'wrong_password' } }
    assert_redirected_to login_path
    assert_equal(I18n.t(:invalid_email_or_password, scope: [:flash, :alert]), flash[:alert])
  end

  test 'destroy session' do
    ##creation
    user = User.first
    post login_path, params: { user: { email: user.email, password: 'password' }, remember_me: 'yes' }

    ## destuction
    delete logout_path
    assert_nil(session[:remember_me])
    assert_nil(session[:user_id])
    assert_equal(I18n.t(:logout_successfull, scope: [:flash, :notice]), flash[:notice])
  end
end
