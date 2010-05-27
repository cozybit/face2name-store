module EventsHelper
  STATUS_MESSAGES = {
    :paid => 'paid',
    :downloaded => 'locked',
    :unpaid => 'new'
  }

  def display_event_status(event)
    STATUS_MESSAGES.fetch(event.status, STATUS_MESSAGES[:unpaid])
  end

  def humanize_event_status(status)
    STATUS_MESSAGES[status]
  end

  def registration_url(event)
    request.protocol + request.host_with_port + new_event_attendee_path(event, { :key => event.registration_key }) 
  end

  def event_date_status(event)
    return 'past' if event.not_after < Date.today
    return 'future' if event.not_before > Date.today
    return 'present'
  end

end
