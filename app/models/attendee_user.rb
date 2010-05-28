class AttendeeUser
  attr_accessor :attendee_id

  def initialize(id)
    @attendee_id = id
  end

  def attendee?
    true
  end

  def admin?
    false
  end

  def email
    return 'registrant'
  end

  def events
    return []
  end
end