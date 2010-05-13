require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @event = events(:one)
  end

  def testuser_signin
    @user = users(:testuser) # from test fixtrure
    sign_in @user
    assert @controller.user_signed_in?
  end
  
  test "should get index" do
    # should fail without authentication
    get :index
    assert_response 302
    
    self.testuser_signin
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "should get new" do
    # should fail without authentication
    get :new
    assert_response 302
    
    # once signed in, should be available
    self.testuser_signin
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
    self.testuser_signin
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
    self.testuser_signin
    get :show, :id => @event.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @event.to_param
    # should fail without authentication
    assert_response 302

    # once signed in, should be available
    self.testuser_signin
    get :edit, :id => @event.to_param
    assert_response :success
  end

  test "should update event" do
    put :update, :id => @event.to_param, :event => { :name=>'test event', :admin_password=>'simple'}
    # should fail without authentication
    assert_response 302

    # once signed in, should be available
    self.testuser_signin
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
    self.testuser_signin
    assert_difference('Event.count', difference=-1) do
      delete :destroy, :id => @event.to_param
    end

    assert_redirected_to events_path
  end
end
