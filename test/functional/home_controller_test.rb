require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "new event should be blocked without signin" do
    get :index
    assert_response 302
  end

  test "should allow new event after signin" do
    self.signin_as_testuser
    get :index
    assert_response :success
  end
end
