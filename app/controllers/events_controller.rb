require 'create_config_bundle'
require 'google_checkout'
require 'date'
require 'nokogiri'

class EventsController < ApplicationController
  load_and_authorize_resource

  def index
    @events = current_user.admin?? Event.all : current_user.events

    @events.sort! { |a, b| b.not_after <=> a.not_after }
  end

  def show
    @event = ::Event.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def edit
    @event = Event.find(params[:id])

    return redirect_to event_url(@event) if @event.downloaded?
  end

  def create
    @event = current_user.events.build(params[:event])
    @event.status = :paid if current_user.is_unlimited?
    
    if @event.save
      redirect_to(@event, :notice => 'Event was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @event = Event.find(params[:id])

    return redirect_to event_url(@event) if @event.downloaded?

      if @event.update_attributes(params[:event])
        redirect_to(@event, :notice => 'Event was successfully updated.')
      else
        render :action => "edit"
      end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    redirect_to(events_url)
  end

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

    filename = @event.name.gsub(/[\W]/, '_').slice(0,40) + '-' + Date.today.strftime("%Y-%m-%d")+'-users.xml'
    send_data(make_users_xml(@event.attendees), :filename => filename,
              :type => "application/octet-stream")
  end

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

  def confirm_passcode
    attendee = Attendee.find_by_email_and_passcode(params[:email], params[:passcode])

    event = attendee.event

    api_xml = Nokogiri::XML::Builder.new { |xml|
      xml.event {
        xml.name event.name
        xml.not_before event.not_before.strftime("%Y-%m-%d")
        xml.not_after event.not_after.strftime("%Y-%m-%d")
        xml.roster {
          event.attendees.each do |attendee|
            xml.vCard('xmlns' => 'vcard-temp') {
              xml.VERSION '2.0'
              xml.FN attendee.name
              xml.PHOTO {
                xml.TYPE 'JPG'
                xml.BINVAL attendee.photo_data64
              }
            }
          end
        }
      }
    }

    render :xml => api_xml
  end
end
