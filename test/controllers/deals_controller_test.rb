require "test_helper"

class DealsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = User.find_by(id: 4)
    ##login
    post login_path, params: { user: { email: @user.email, password: 'password' } }
  end

  test 'should get index' do
    get deals_path
    assert_response :success
  end

  test 'should get index on basis of search query' do
    get deals_path, params: { search: { deal_text: 'abc' } }
    assert_response :success
  end

  test 'should show a deal' do
    get deal_path(Deal.first)
    assert_response :success
  end

  test 'should not get show if no user is loggedin' do
    #logout
    delete logout_path

    get deal_path(Deal.first)
    assert_response :redirect
    assert_redirected_to login_path
    assert_equal(I18n.t(:login_to_continue, scope: [:flash, :alert]), flash[:alert])
  end

  ## cannot test encrypted/signed cookies
  # test 'should get show by fetching user from cookie' do
  #   #logout
  #   delete logout_path
  #   debugger
  #   cookies.encrypted[:remember_me] = User.find_by(id: 4).try(:remember_me_token)
  #   get deal_path(Deal.first)
  #   assert_response :success
  # end

  test 'should not show invalid deal' do
    get deal_path(id: 0)
    assert_response :missing
    assert_template file: '404.html'
  end

end
