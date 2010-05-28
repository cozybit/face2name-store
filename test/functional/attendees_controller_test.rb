require 'test_helper'
require 'base64'

class AttendeesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @event = events(:attended)  
  end

  test 'should route attendees of event' do
    options = { :controller => 'attendees', :action => 'index', :event_id => '2'}
    assert_routing '/events/2/attendees', options
  end

  test 'should route to new photo for attendee' do
    options = { :controller => 'attendees', :action => 'new_photo', :event_id => '2', :id => '3'}
    assert_routing '/events/2/attendees/3/new_photo', options
  end

  test 'should route to photo upload for attendee' do
    options = { :controller => 'attendees', :action => 'upload_photo', :event_id => '2', :id => '3'}
    assert_routing( { :method => 'post', :path => '/events/2/attendees/3/upload_photo'}, options )
  end

  test 'should route to photo userservice (upload) for attendee' do
    options = { :controller => 'attendees', :action => 'userservice', :event_id => '2', :id => '3'}
    assert_routing( { :method => 'post', :path => '/events/2/attendees/3/userservice'}, options )
  end

  test 'should list attendees for event' do
    signin_as_testuser

    get :index, :event_id => @event.to_param

    assert_response :success
    assert_not_nil assigns(:attendees)
  end

  test 'should display new attendee form' do
    signin_as_testuser

    get :new, :event_id => @event.to_param

    assert_response :success
    assert assigns(:event)
  end

  test 'should create new attendee' do
    signin_as_testuser

    post :create, :event_id => @event.to_param, :attendee => {:name => 'New Attendee', :email => "new@newnew.com"}

    assert_response 302
    assert_redirected_to new_photo_event_attendee_path(@event, assigns(:attendee))
  end

  test 'should render attendee show page' do
    signin_as_testuser

    get :show, :event_id => @event.to_param, :id => attendees(:loretta).to_param
    assert_response :success
    assert assigns(:event)
    assert assigns(:attendee)
  end

  test "should render new_photo page" do
    signin_as_testuser

    get :new_photo, :event_id => @event.to_param, :id => attendees(:loretta).to_param
    assert_response :success
    assigns(:event)
    assert assigns(:attendee)
  end

  test "should accept uploaded photo" do
    signin_as_testuser

    attendee = attendees(:nophoto)
    assert ! attendee.photo.file?

    the_photo = fixture_file_upload('files/paperclips.jpg','image/jpeg')
    post :upload_photo, :event_id => @event.to_param, :id => attendee.to_param, :attendee => { :photo => the_photo }
    assert_response 302
    assert_redirected_to event_attendee_path(@event, assigns(:attendee))

    attendee.reload
    assert attendee.photo.file?
  end

  test 'should redisplay photo page when uploaded data is bad' do
    signin_as_testuser

    attendee = attendees(:nophoto)
    assert ! attendee.photo.file?

    the_photo = []
    post :userservice, :event_id => @event.to_param, :id => attendee.to_param, :fileData => the_photo

    assert_response 302
    assert_redirected_to upload_photo_event_attendee_path(@event, assigns(:attendee))
  end

  test 'should accept base64 encoded photo as post parameter' do
    signin_as_testuser

    attendee = attendees(:nophoto)
    assert ! attendee.photo.file?

    the_photo = Base64.encode64(File.read(File.join(Rails.root, 'test', 'fixtures', 'files', 'paperclips.jpg')))

    post :userservice, :event_id => @event.to_param, :id => attendee.to_param, :fileData => the_photo

    assert_response 302
    assert_redirected_to event_attendee_path(@event, assigns(:attendee))

    attendee.reload
    assert attendee.photo.file?
  end

end