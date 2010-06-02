class Ability
  include CanCan::Ability

  REGISTRATION_ACTIONS = [ :show, :new_photo, :upload_photo, :userservice ]

  def initialize(user)

    if !user.nil?
      if user.admin?
        can :manage, :all
        return
      elsif user.respond_to? :registrant? # i.e. temporary registrant
        set_tmp_registrant_abilities(user)
        return
      else
        set_event_manager_abilities(user)
      end
    end

    can :register, Attendee
    can :confirm_passcode, Event
  end

  def set_tmp_registrant_abilities(user)
    can [ :create ], Attendee
    can REGISTRATION_ACTIONS, Attendee, :id => user.attendee_id

    can :confirm_passcode, Event
  end

  def set_event_manager_abilities(user)
    can [ :manage ], Event, :user_id => user.id
    can [ :index, :create ], Event

    #can :manage, Attendee do |unused, attendee|
    #  attendee.nil? or attendee.event.nil? or attendee.event.user_id == user.id
    #end

    can [ :manage ], Attendee do |action, attendee|
      attendee && attendee.event.user_id == user.id
    end
    
    can [ :index, :create ], Attendee
    can :confirm_passcode, Event
  end
end
