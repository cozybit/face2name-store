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

  test 'should display new attendee form' do
    get :new, :event_id => @event.to_param

    assert_response :success
    assert assigns(:event)
  end

  test 'should create new attendee' do
    post :create, :event_id => @event.to_param, :attendee => {:name => 'New Attendee', :email => "new@newnew.com"}

    assert_response 302
    assert_redirected_to event_attendee_path(@event, assigns(:attendee))
  end

  test 'should render attendee show page' do
    get :show, :event_id => @event.to_param, :id => attendees(:loretta).to_param
    assert_response :success
    assert assigns(:event)
    assert assigns(:attendee)
  end
  
end