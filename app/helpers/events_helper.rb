module EventsHelper
  def display_status(event)
    case event.status
      when :paid
        'Paid (Editable)'
      when :downloaded
        'Downloaded (Uneditable)'
      else
        'New (Editable)'
    end  
  end
end
