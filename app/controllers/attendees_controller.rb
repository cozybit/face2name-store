class AttendeesController < ApplicationController
  before_filter :load_event

  def index
    @attendees = @event.attendees
  end

  def new
    @attendee = Attendee.new
  end

  def create
    @attendee = @event.attendees.build(params[:attendee])

    if @attendee.save
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
    @attendee.update_attributes( params[:attendee] )

    return redirect_to event_attendee_path(@event, @attendee)
  end
  private

  def load_event
    @event = Event.find(params[:event_id])
  end
end