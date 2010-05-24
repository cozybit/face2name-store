require 'test_helper'

class AttendeesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @event = events(:attended)  
  end

  test 'should route attendees of event' do
    options = { :controller => 'attendees', :action => 'index', :event_id => '2'}
    assert_routing '/events/2/attendees', options
  end

  test 'should list attendees for event' do
    get :index, :event_id => @event.to_param

    assert_response :success
    assert_not_nil assigns(:attendees)
  end

  test 'should show new attendee form' do
    get :new, :event_id => @event.to_param

    assert_response :success
    assert assigns(:event)
  end
end