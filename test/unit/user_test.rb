require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
#  test "role is not mass assignable" do
#    u = User.new({:role => 'admin'})
#    assert nil == u.role
#  end

  test "admin? is true for users with admin role" do
    u = User.new
    u.role = 'manager'
    assert !u.admin?
    u.role = 'admin'
    assert u.admin?
  end
end
