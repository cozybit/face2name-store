require 'test_helper'

class AttendeesControllerTest < ActionController::TestCase
  def setup
    @event = events(:attended)  
  end

  test 'should route attendees of event' do
    options = { :controller => 'attendees', :action => 'index', :event_id => '2'}
    assert_routing '/events/2/attendees', options
  end

  test 'should list attendees for event' do
    get :event_id =
  end
end