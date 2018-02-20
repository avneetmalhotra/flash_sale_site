require "test_helper"

class ConfirmationControllersTest < ActionDispatch::IntegrationTest

  test 'should get new' do
    get new_confirmation_path
    assert_response :success
  end

  test 'should post create' do
    user = User.first
    user.update_columns(confirmed_at: nil)
    post confirmations_path, params: { email: user.email }
    assert_response :redirect
    assert_redirected_to login_path
    assert_equal(I18n.t(:confirmation_email_sent, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not post create due to invalid user' do
    post confirmations_path, params: { email: 'invalid@mail.com' }
    assert_response :redirect
    assert_redirected_to new_confirmation_path
    assert_equal(I18n.t(:invalid_account, scope: [:flash, :alert]), flash[:alert])
  end

  test 'should confirm' do
    user = User.first
    user.update_columns(confirmed_at: nil, confirmation_token_sent_at: 20.minutes.before)
    get user_confirm_path, params: { confirmation_token: user.confirmation_token }
    assert_response :redirect
    assert_redirected_to login_path
    assert_equal(I18n.t(:account_confirmed, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not confirm due to invalid user' do
    get user_confirm_path, params: { confirmation_token: 'invalidToken' }
    assert_response :missing
    assert_template file: '404.html'
  end

  test 'should not confirm already confimed' do
    user = User.first
    user.update_columns(confirmation_token_sent_at: 20.minutes.before)
    get user_confirm_path, params: { confirmation_token: user.confirmation_token }
    assert_response :redirect
    assert_redirected_to login_path
    assert_equal(I18n.t(:account_already_confirmed, scope: [:flash, :alert]), flash[:alert])
  end

  test 'should not confirm when token has expired' do
    user = User.first
    user.update_columns(confirmed_at: nil)
    get user_confirm_path, params: { confirmation_token: user.confirmation_token }
    assert_response :redirect
    assert_redirected_to login_path
    assert_equal(I18n.t(:invalid_confirmation_token, scope: [:flash, :alert]), flash[:alert])
  end

end
