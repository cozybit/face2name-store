require 'create_config_bundle'
require 'google_checkout'

class EventsController < ApplicationController
  before_filter :authenticate_user!
  # GET /events
  # GET /events.xml
  def index
    @events = current_user.is_admin?? Event.all : current_user.events

    @events.sort! { |a, b| b.not_before <=> a.not_before }

    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => @events }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.haml
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.haml
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])

    return redirect_to event_url(@event) if @event.downloaded?
  end

  # POST /events
  # POST /events.xml
  def create
    @event = current_user.events.build(params[:event])
    @event.status = :paid if current_user.is_unlimited?
    
    respond_to do |format|
      if @event.save
        format.html { redirect_to(@event, :notice => 'Event was successfully created.') }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])

    return redirect_to event_url(@event) if @event.downloaded?

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to(@event, :notice => 'Event was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end

  # GET /event/1/configuration
  def configuration
    @event = Event.find( params[:id] )

    return redirect_to event_url(@event) if !@event.downloadable?
    
    config_bundle_fname, temp_dir = make_configuration_bundle( @event )

    short_fname = File.basename( config_bundle_fname )
    send_data(File.open(config_bundle_fname, 'r').read(), :filename => short_fname,
              :type => "application/octet-stream")

    @event.update_attribute(:status, :downloaded)
    if F2N[:cleanup_configs]
      cleanup( temp_dir )
    end
  end

  def attendee_list
    @event = Event.find( params[:id] )

    send_data(make_users_xml(@event.attendees), :filename => @event.name.gsub(/[\W]{1,}/, '_') + '_users.xml',
              :type => "application/octet-stream")
  end

  # GET /event/1/purchase
  def purchase
    @event = Event.find(params[:id])

    response = initiate_event_purchase(@event, url_for(:action => :confirm, :key => @event.download_key))

    redirect_to response.redirect_url
  end

  def confirm
    @event = Event.find(params[:id])

    if (@event.download_key == params[:key])
      @event.update_attribute(:status, :paid)
      redirect_to(@event, :notice => 'Thank you for your purchase.')
    else
      redirect_to '/403.html', :status => 403
    end
  end
end
