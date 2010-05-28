require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  EVENT_MODIFICATIONS = [:edit, :destroy, :update, :configuration, :attendee_list, :purchase, :confirm]
  EVENT_CREATIONS = [:new, :create, :index]

  ATTENDEE_REGISTRATION_CLASS = [:new, :create]
  ATTENDEE_REGISTRATION_INSTANCE = [:show, :new_photo, :upload_photo, :userservice]

  ATTENDEE_EVENT_OWNER_CLASS = [:index, :new, :create]
  ATTENDEE_EVENT_OWNER_INSTANCE = [:edit, :destroy, :update, :show, :upload_photo, :userservice]

  ATTENDEE_CLASS = ATTENDEE_REGISTRATION_CLASS + ATTENDEE_EVENT_OWNER_CLASS
  ATTENDEE_INSTANCE = ATTENDEE_REGISTRATION_INSTANCE + ATTENDEE_EVENT_OWNER_INSTANCE

  def can_cannot(ability, actions, can_object, cannot_object)
    actions.each do |action|
      assert ability.can?(action, can_object), "can failure: action: #{action}" if can_object
      assert ability.cannot?(action, cannot_object), "cannot failure: action: #{action}" if cannot_object
    end
  end

  test 'logged in event manager can manage only events they own' do
    user = User.new()
    user.id = 666
    ability = Ability.new(user)
    can_cannot(ability, EVENT_CREATIONS, Event, nil)
    can_cannot(ability, EVENT_MODIFICATIONS, Event.new(:user_id => user.to_param), Event.new(:user_id => 898))

  end

  test 'admin can manage any event' do
    user = User.new()
    user.role = 'admin'
    user.id = 'admin'

    ability = Ability.new(user)
    can_cannot(ability, EVENT_CREATIONS, Event, nil)
    can_cannot(ability, EVENT_MODIFICATIONS, Event.new(:user_id => 888), nil)
  end

  test 'temporary registrants cannot do anything with events' do
    user = TmpRegistrationCredentials.new

    ability = Ability.new(user)
    can_cannot(ability, EVENT_CREATIONS, nil, Event)
    can_cannot(ability, EVENT_MODIFICATIONS, nil, Event.new(:user_id => 888))
  end

  test 'anonymous users cannot manage events' do
    ability = Ability.new(nil)
    can_cannot(ability, EVENT_CREATIONS, nil, Event)
    can_cannot(ability, EVENT_MODIFICATIONS, nil, Event.new(:user_id => 888))
  end

  test 'anonymous users cannot do anything but register with attendees' do
    ability = Ability.new(nil)

    event = Event.new(:user_id => 666)
    cant_attendee = event.attendees.new
    cant_attendee.id = 888

    can_cannot(ability, [:register], Attendee, nil)
    can_cannot(ability, ATTENDEE_CLASS, nil, Attendee)
    can_cannot(ability, ATTENDEE_INSTANCE, nil, cant_attendee)
  end

  test 'temporary registrants can complete the registration path on attendees' do
    tmp_user = TmpRegistrationCredentials.new

    ability = Ability.new(tmp_user)

    event = Event.new(:user_id => 666)
    can_attendee = event.attendees.new
    can_attendee.id = 666

    cant_attendee = event.attendees.new
    cant_attendee.id = 888

    can_cannot(ability, ATTENDEE_REGISTRATION_CLASS, Attendee, nil)
    can_cannot(ability, Set.new(ATTENDEE_CLASS) - Set.new(ATTENDEE_REGISTRATION_CLASS), nil, Attendee)

    tmp_user.attendee_id = 666
    ability = Ability.new(tmp_user)
    can_cannot(ability, ATTENDEE_REGISTRATION_INSTANCE, can_attendee, cant_attendee)
    can_cannot(ability, Set.new(ATTENDEE_INSTANCE) - Set.new(ATTENDEE_REGISTRATION_INSTANCE), nil, can_attendee)
  end

  test 'event managers can manage attendees for their own events' do
    tmp_user = TmpRegistrationCredentials.new

    ability = Ability.new(tmp_user)

    event = Event.new(:user_id => 666)
    can_attendee = event.attendees.new
    can_attendee.id = 666

    cant_attendee = event.attendees.new
    cant_attendee.id = 888

    can_cannot(ability, ATTENDEE_REGISTRATION_CLASS, Attendee, nil)
    can_cannot(ability, Set.new(ATTENDEE_CLASS) - Set.new(ATTENDEE_REGISTRATION_CLASS), nil, Attendee)

    tmp_user.attendee_id = 666
    ability = Ability.new(tmp_user)
    can_cannot(ability, ATTENDEE_REGISTRATION_INSTANCE, can_attendee, cant_attendee)
    can_cannot(ability, Set.new(ATTENDEE_INSTANCE) - Set.new(ATTENDEE_REGISTRATION_INSTANCE), nil, can_attendee)
  end

  test 'event managers can manage attendees' do
    user = User.new
    user.id = 666

    ability = Ability.new(user)

    event = Event.new(:user_id => 666)
    can_attendee = Attendee.new(:event => event)
    can_attendee.id = 666

    event = Event.new(:user_id => 898)
    cant_attendee = Attendee.new(:event => event)
    cant_attendee.id = 555

    can_cannot(ability, ATTENDEE_CLASS, Attendee, nil)
    can_cannot(ability, ATTENDEE_INSTANCE, can_attendee, cant_attendee)
  end
end