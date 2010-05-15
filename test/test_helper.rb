ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  self.use_transactional_fixtures = true
  
  # Add more helper methods to be used by all tests here...
  def signin_as_testuser
    @user = users(:testuser) # from test fixtrure
    @controller.sign_in @user
    assert @controller.user_signed_in?
  end

end
