require 'test_helper'

class AttendeeTest < ActiveSupport::TestCase
  test 'email validation is reasonable' do
    attendee = Attendee.new({:name => 'valid name', :email => 'foo'})

    assert !attendee.valid?

    attendee.email = 'erik@carbonfive.com'

    assert attendee.valid?
  end

  test 'passcode is assigned on creation' do
    attendee = Attendee.new({:name => 'valid name', :email => 'foo@carbonfive.com'})
    attendee.save

    assert_equal 6, attendee.passcode.length
  end
end