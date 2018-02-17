require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest

  def login
    @user = User.first
    post login_path, params: { user: { email: @user.email, password: 'password' } }
  end

  test 'should get new' do
    get new_registration_path
    assert_response :success
  end

  test 'should create user' do
    assert_difference 'User.count' do
      post registrations_path, params: { user: { name: 'new_user', email: 'new_user@mail.com', 
        password: 'password', password_confirmation: 'password' } }
    end
    assert_redirected_to login_path
    assert_equal(I18n.t(:confirmation_email_sent, scope: [:flash, :notice]), flash[:notice])
  end

  test 'should not create user' do
    assert_no_difference 'User.count' do
      post registrations_path, params: { user: { name: 'wefwf' } }
      assert_response :success
      assert_template 'new'
    end
  end

  test 'should get edit' do
    login
    get edit_registration_path(@user)
    assert_response :success
  end

  test 'should update user' do
    login
    patch registration_path(@user), params: { user: { name: 'new_user_name', password: 'new_pass', 
      password_confirmation: 'new_pass', current_password: 'password' } }
    assert_redirected_to root_url
    assert_equal(I18n.t(:account_updated, scope: [:flash, :notice]), flash[:notice])
    @user.reload
    assert_equal(@user.name, 'new_user_name')
  end

  test 'cannot upadate user' do
    login
    patch registration_path(@user), params: { user: { name: 'new_user_name', password: 'new_pass', 
      password_confirmation: 'new_pass', current_password: 'wrong_password' } }
    assert_template 'edit'
    @user.reload
    assert_not_equal(@user.name, 'new_user_name')
  end

  test 'cannot edit any other user other than loginned' do
    login
    other_user = User.second
    get edit_registration_path(other_user)
    assert_template file: '404.html'
    assert_response :missing
  end
end
