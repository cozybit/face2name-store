class Ability
  include CanCan::Ability

  def initialize(user)
    can :register, Attendee

    if user.nil?
      return
    end
    
    if user.admin?
      can :manage, :all
    elsif user.respond_to? :attendee?
      can [ :create ], Attendee
      can [ :update, :read, :new_photo, :upload_photo ], Attendee, :id => user.attendee_id
    else # signed in user
      can [ :index, :create ], Event
      can [ :read, :update, :destroy ], Event, :user_id => user.id
      can [ :read, :update, :destroy ], Attendee do |action, attendee|
        attendee.nil? or attendee.event.nil? or attendee.event.user_id == user.id
      end
    end
  end
end
