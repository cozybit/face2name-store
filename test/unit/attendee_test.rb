
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

  test 'should thumnail photo and upload to s3' do
    attendee = Attendee.create({:name => 'valid name', :email => 'foo'})
    attendee.photo = File.open(Rails.root.join('test', 'fixtures', 'files', 'paperclips.jpg'), 'r')
    attendee.save

    assert_match %r"^http://s3.amazonaws.com/face2name-store/photos", attendee.photo.url(:thumb)
  end

end