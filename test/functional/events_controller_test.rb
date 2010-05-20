require 'test_helper'
require 'date'

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

  test "should get index showing only events belonging to user" do
    ids = users(:testuser).events.collect { |e| e.id }

    self.signin_as_testuser
    get :index

    events = assigns(:events)
    assert_equal ids.length, events.length

    events.each do |e|
      assert ids.pop(e.id)
    end
  end

  test "should get index showing all events for admin" do
    @controller.sign_in users(:testadmin)

    get :index

    assert_equal Event.all.length, assigns(:events).length
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
      post :create, :event => { :name=>'test event', :admin_password=>'simple', :not_before => Date.today(), :not_after => Date.today + 3 }
    end

    assert assigns(:event).user == users(:testuser)
    assert_redirected_to event_path(assigns(:event))
  end

  test "new event for limited users are not marked PAID" do
    # once signed in, should be available
    self.signin_as_testuser
    post :create, :event => { :name=>'test event', :admin_password=>'simple', :not_before => Date.today(), :not_after => Date.today + 3 }

    assert assigns(:event).status != :paid
  end

  test "new event for unlimted users are marked PAID" do
    # once signed in, should be available
    @controller.sign_in users(:unlimited)
    post :create, :event => { :name=>'test event', :admin_password=>'simple', :not_before => Date.today(), :not_after => Date.today + 3 }

    assert assigns(:event).status == :paid
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

  test "should redirect to show when trying to edit a downloaded event" do
    self.signin_as_testuser
    event = events(:downloaded)

    get :edit, :id => event.to_param
    assert_redirected_to event_path(event)
  end

  test "should update event only when authenticated" do
    original_name = @event.name
    put :update, :id => @event.to_param, :event => { :name=>'updated event', :admin_password=>'simple'}
    # should fail without authentication
    assert_response 302

    @event.reload
    assert_equal original_name, @event.name

    # once signed in, should be available
    self.signin_as_testuser
    put :update, :id => @event.to_param, :event => { :name=>'updated event', :admin_password=>'simple' }
    assert_redirected_to event_path(assigns(:event))

    @event.reload
    assert_equal 'updated event', @event.name
  end

  test "destroy event should fail without signin" do

    # should fail without authentication
    assert_difference('Event.count', difference=0) do
      delete :destroy, :id => @event.to_param
    end
    assert_response 302
  end

  test "should destroy event" do

    # once signed in, should be available
    self.signin_as_testuser
    assert_difference('Event.count', difference=-1) do
      delete :destroy, :id => @event.to_param
    end

    assert_redirected_to events_path
  end

  test "should redirect configuration request for unpaid event" do
    self.signin_as_testuser

    get :configuration, :id => @event.to_param
    assert_redirected_to event_path( assigns( :event ))
  end

  test "should create event configuration for paid event" do
    self.signin_as_testuser

    get :configuration, :id => events(:paid).to_param
    assert_match %r{application\/octet-stream}, @response.headers["Content-Type"]
  end

  test "should mark event as downloaded" do
    self.signin_as_testuser

    event = events(:paid)
    get :configuration, :id => event.to_param

    event.reload
    assert event.downloaded?
  end

  test "should redirect to payment gateway url" do
    self.signin_as_testuser
    assert @event.status == nil

    get :purchase, :id => @event.to_param

    @event.reload
    assert @event.status == 'UNPAID'

    assert_response 302
    assert response.location.match(/google\.com/)
  end

  test 'should fail to confirm event purchase' do
    self.signin_as_testuser

    get :confirm, :id => @event.to_param, :key => @event.download_key + 'foo'

    assert @event.status != :paid

    assert_response 403
  end

  test 'should confirm event purchase' do
    self.signin_as_testuser
    
    get :confirm, :id => @event.to_param, :key => @event.download_key

    @event.reload
    assert_redirected_to event_path(assigns( :event ))
    assert_equal :paid, @event.status
  end

  test 'should ignore updating of downloaded event' do
    event = events(:downloaded)

    original_name = event.name

    self.signin_as_testuser

    put :update, :id => event.to_param, :event => { :name=>'update downloaded', :admin_password=>'simple' }

    event.reload
    assert_equal original_name, event.name

    assert_redirected_to event_path(assigns(:event))
  end
end
