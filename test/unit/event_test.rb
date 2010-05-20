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

  test "event initialization populates download key" do
    event = Event.create(:not_before => Date.today(), :not_after => Date.today() + 3, :admin_password => 'simple', :name => 'foo')

    assert event.download_key != nil
    assert event.download_key.length == 16
  end
end
