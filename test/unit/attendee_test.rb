require 'test_helper'
require 'base64'
require "image_size"

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
    attendee = Attendee.create({:name => 'valid name', :email => 'foo@foo.com'})
    attendee.photo = File.open(Rails.root.join('test', 'fixtures', 'files', 'paperclips.jpg'), 'r')
    attendee.save

    assert_match %r"^http://s3.amazonaws.com/f2n-store-.*/photos", attendee.photo.url(:thumb)
  end

  test 'should return valid b64 encoded image from s3' do
    attendee = Attendee.create({:name => 'valid name', :email => 'foo@foo.com'})
    attendee.photo = File.open(Rails.root.join('test', 'fixtures', 'files', 'paperclips.jpg'), 'r')
    attendee.save

    thumb_bytes = Base64.decode64(attendee.photo_data64)
    assert_equal [200, 200], ImageSize.new(thumb_bytes).get_size
  end
end