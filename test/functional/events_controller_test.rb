require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @event = events(:one)
  end

  test "should get index" do
    # should fail without authentication
    get :index
    assert_response 302
    
    self.signin_as_testuser
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "new event should be blocked without signin" do
    # should fail without authentication
    get :new
    assert_response 302
  end
  
  test "should allow new event after signin" do

    # once signed in, should be available
    self.signin_as_testuser
    get :new
    assert_response :success
  end

  test "create event should fail without sign in" do
    assert_no_difference('Event.count') do
      post :create, :event => { :name=>'test event', :admin_password=>'simple'}
    end

    # should fail without authentication
    assert_response 302
  end
  test "create event after sign in" do
    # once signed in, should be available
    self.signin_as_testuser
    assert_difference('Event.count') do
      post :create, :event => { :name=>'test event', :admin_password=>'simple'}
    end

    assert_redirected_to event_path(assigns(:event))
  end

  test "should show event" do
    get :show, :id => @event.to_param
    # should fail without authentication
    assert_response 302

    # once signed in, should be available
    self.signin_as_testuser
    get :show, :id => @event.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @event.to_param
    # should fail without authentication
    assert_response 302

    # once signed in, should be available
    self.signin_as_testuser
    get :edit, :id => @event.to_param
    assert_response :success
  end

  test "should update event" do
    put :update, :id => @event.to_param, :event => { :name=>'test event', :admin_password=>'simple'}
    # should fail without authentication
    assert_response 302

    # once signed in, should be available
    self.signin_as_testuser
    put :update, :id => @event.to_param, :event => { :name=>'test event', :admin_password=>'simple'}
    assert_redirected_to event_path(assigns(:event))
  end

  test "should destroy event" do

    # should fail without authentication
    assert_difference('Event.count', difference=0) do
      delete :destroy, :id => @event.to_param
    end
    assert_response 302

    # once signed in, should be available
    self.signin_as_testuser
    assert_difference('Event.count', difference=-1) do
      delete :destroy, :id => @event.to_param
    end

    assert_redirected_to events_path
  end
end
