require 'base64'
require 'tempfile'

class AttendeesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:userservice]

  before_filter :load_event

  load_and_authorize_resource :nested => :event

  def current_ability
    if [:new, :create, :new_photo, :upload_photo, :show ].member? request[:action].to_sym
      user = session[:tmp_registrant]
    end

    user ||= current_user

    @current_ability ||= Ability.new(user)
  end

  def index
    authorize! :read, @event
    @attendees = @event.attendees
  end

  def register
    if @event.registration_key == params[:key]
      session[:tmp_registrant] = TmpRegistrationCredentials.new
      redirect_to new_event_attendee_path(@event, @attendee)
    else
      redirect_to '/403.html', :status => 403
    end
  end

  def new
    @attendee = Attendee.new
  end

  def create
    @attendee = @event.attendees.build(params[:attendee])

    if @attendee.save
      session[:tmp_registrant].attendee_id = @attendee.id if session[:tmp_registrant]

      redirect_to(new_photo_event_attendee_path(@event, @attendee), :notice => 'Attendee was successfully created.')
    else
      render :action => "new"
    end
  end

  def show
    @attendee = Attendee.find(params[:id])
  end

  def new_photo
    @attendee = Attendee.find(params[:id])
  end

  def upload_photo
    @attendee = Attendee.find(params[:id])
    if @attendee.update_attributes( params[:attendee] )
      redirect_to event_attendee_path(@event, @attendee)
    else
      redirect_to upload_photo_event_attendee_path(@event, @attendee)
    end
  end

  def userservice
    @attendee = Attendee.find(params[:id])

    if params[:fileData] == nil or params[:fileData].length < 1
      return redirect_to upload_photo_event_attendee_path(@event, @attendee)
    end

    image_data = Base64.decode64(params[:fileData])

    tmp = Tempfile.new('photo_upload', File.join(Rails.root, 'tmp'))
    tmp.write(image_data)
    tmp.flush

    File.open(tmp.path, 'r') do |f|
      @attendee.photo = f
    end

    if @attendee.save
      redirect_to event_attendee_path(@event, @attendee)
    else
      redirect_to upload_photo_event_attendee_path(@event, @attendee)
    end
  end

  private

  def load_event
    @event = Event.find(params[:event_id])
  end
end