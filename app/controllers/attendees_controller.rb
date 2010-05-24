class AttendeesController < ApplicationController
  before_filter :load_event

  def index
    @attendees = @event.attendees
  end

  private

  def load_event
    @event = Event.find(params[:event_id])
  end
end