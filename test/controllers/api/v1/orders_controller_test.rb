require 'test_helper'

class Api::V1::OrdersControllerTest < ActionDispatch::IntegrationTest

  test 'should get index' do
    get api_v1_orders_path, params: { token: User.first.api_token }
    assert_response :success
  end

  test 'should not get index for invalid api token' do
    get api_v1_orders_path, params: { token: 'invalid_token' }
    assert_response 401
  end
end
