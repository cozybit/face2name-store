require 'test_helper'
require 'date'

class EventTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "event duration must be at least one day" do
    event = Event.new(:not_before => Date.today(), :not_after => Date.today() + 3, :admin_password => 'simple', :name => 'foo' )
    assert event.valid?
    event = Event.new(:not_before => Date.today(), :not_after => Date.today(), :admin_password => 'simple', :name => 'foo' )
    assert !event.valid?
  end

  test "event duration cannot be greater than 21 days" do
    today = Date.today()
    event = Event.new(:not_before => today, :not_after => today + 21, :admin_password => 'simple', :name => 'foo' )
    assert event.valid?
    event = Event.new(:not_before => today, :not_after => today + 22, :admin_password => 'simple', :name => 'foo' )
    assert !event.valid?
  end

  test "event initialization populates download key" do
    event = Event.create(:not_before => Date.today(), :not_after => Date.today() + 3, :admin_password => 'simple', :name => 'foo')

    assert event.download_key != nil
    assert event.download_key.length == 16
  end

  test "Event should reject bad chars in name" do
    event_name = 'good chars only'
    event = Event.new( :name => event_name, :not_before => Date.today(), :not_after => Date.today() + 3, :admin_password => 'simple')
    assert event.valid?, "good chars should work"
    assert_equal 0, event.errors.length

    event_name = 'bad , char'
    event = Event.new( :name => event_name, :not_before => Date.today(), :not_after => Date.today() + 3, :admin_password => 'simple')
    assert ! event.valid?, "comma should fail"
    assert_match /event name/i, event.errors[:name].to_s

    event_name = 'bad $ char'
    event = Event.new( :name => event_name, :not_before => Date.today(), :not_after => Date.today() + 3, :admin_password => 'simple')
    assert ! event.valid?, "dollar sign should fail"
    assert_match /event name/i, event.errors[:name].to_s

  end

  test "Event should allow names up to 63 chars" do
    event_name = 'a'*63
    event = Event.new( :name => event_name, :not_before => Date.today(), :not_after => Date.today() + 3, :admin_password => 'simple')
    assert event.valid?, '63 chars should be ok'

    event_name = 'a'*64
    event = Event.new( :name => event_name, :not_before => Date.today(), :not_after => Date.today() + 3, :admin_password => 'simple')
    assert ! event.valid?, '64 chars should be invalid'
  end
end
