require "test_helper"

class Api::V1::DealsControllerTest < ActionDispatch::IntegrationTest

  test 'should get live' do
    get live_api_v1_deals_path
    assert_response :success
  end

  test 'should get expired' do
    get expired_api_v1_deals_path
    assert_response :success
  end
end
