require 'create_config_bundle'

class Attendee < ActiveRecord::Base
  belongs_to :event

  has_attached_file :photo, { :styles => { :thumb => "200x200#" }}.merge(F2N[:paperclip_info])

  validates :name, :presence => true, :length => { :within => 1..63 }
  validates_format_of :email,
                      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                      :message => 'doesn\'t appear to be a valid email address'

  before_create :set_passcode

  def set_passcode
    self.passcode = make_passcode
  end
end