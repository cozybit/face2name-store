require 'test_helper'
require 'base64'
require 'image_size'

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

  test 'cannot have two attendees with same email for same event' do
    attendee = Attendee.new({:name => 'Loretta Two', :email => 'loretta@attendee.com', :event_id => events(:attended).to_param})

    assert !attendee.valid?
  end

  test 'can have two attendees with same email register for different events' do
    attendee = Attendee.new({:name => 'Loretta Two', :email => 'loretta@attendee.com', :event_id => events(:one).to_param})

    assert attendee.valid?
  end

  test 'cannot have two attendee records with same email and passcode' do
    attendee = Attendee.new({:name => 'Loretta Two', :email => 'loretta@attendee.com', :event_id => events(:one).to_param, :passcode => 'ABCDEF'})

    assert !attendee.valid?
  end

  test 'attendee generates passcodes until email:passcode combination is unique' do
    values = 'ABCDEF', 'ABCDEF', 'ABCDEF', 'UNIQUE'
    Passcode.stubs(:make_passcode).returns(*values)
    attendee = Attendee.create({:name => 'Loretta Two', :email => 'loretta@attendee.com', :event_id => events(:one).to_param})

    assert_equal values.last, attendee.passcode
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