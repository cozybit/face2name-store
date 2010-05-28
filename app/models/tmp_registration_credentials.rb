class TmpRegistrationCredentials
  attr_accessor :attendee_id

  def registrant?
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