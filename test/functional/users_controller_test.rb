require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "index of users should be blocked without admin sign in" do
    get :index
    assert_response 302
  end

  test "index of users should be blocked with user sign in" do
    self.signin_as_testuser
    get :index
    assert_response 403
  end

  test "should allow index of users after admin sign in" do
    @controller.sign_in users(:testadmin)
    get :index
    assert_response :success
  end
end