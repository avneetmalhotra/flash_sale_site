require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest

  test 'should get new' do
    get new_password_path
    assert_response :success
  end

  test 'should post create' do
    user = User.first
    post passwords_path, params: { email: user.email }
    assert_response :redirect
    assert_redirected_to login_path
    assert_equal(I18n.t(:password_reset_email_sent, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not post create' do
    post passwords_path, params: { email: 'unknown_email@mail.com' }
    assert_response :redirect
    assert_redirected_to new_password_path
    assert_equal(I18n.t(:invalid_account, scope: [:flash, :alert]), flash[:alert])
  end

  test 'should get edit' do
    user = User.third
    user.update_columns(password_reset_token_sent_at: 20.minutes.before)
    get password_reset_path, params: { password_reset_token: user.password_reset_token }
    assert_response :success
  end

  test 'should patch update' do
    user = User.third
    user.update_columns(password_reset_token_sent_at: 20.minutes.before)
    patch password_reset_path, params: { password_reset_token: user.password_reset_token, 
      user: { password: 'new_pass', password_confirmation: 'new_pass' } }
    assert_response :redirect
    assert_redirected_to login_path
    assert_equal(I18n.t(:password_successfully_reset, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not pathch update' do
    user = User.third
    user.update_columns(password_reset_token_sent_at: 20.minutes.before)
    patch password_reset_path, params: { password_reset_token: user.password_reset_token, 
      user: { password: 'wrong_pass', password_confirmation: 'wrong_wrong_pass' } }
    assert_response :success
    assert_template 'edit'
  end

  test 'should not get edit due to invalid user' do
    get password_reset_path, params: { password_reset_token: 'ahjbfehbf' }
    assert_response :missing
    assert_template file: '404.html'
  end

  test 'should not get edit due to expired token' do
    user = User.third
    get password_reset_path, params: { password_reset_token: user.password_reset_token }
    assert_response :redirect
    assert_redirected_to login_path
    assert_equal(I18n.t(:invalid_password_reset_token, scope: [:flash, :alert]), flash[:alert])
  end

end
