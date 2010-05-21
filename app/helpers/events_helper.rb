module EventsHelper
  STATUS_MESSAGES = {
    :paid => 'Paid (Editable)',
    :downloaded => 'Downloaded (Locked)',
    :unpaid => 'New (Editable)'
  }

  def display_event_status(event)
    STATUS_MESSAGES.fetch(event.status, STATUS_MESSAGES[:unpaid])
  end

  def humanize_event_status(status)
    STATUS_MESSAGES[status]
  end
end
