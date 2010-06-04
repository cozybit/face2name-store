class EventValidator < ActiveModel::Validator
  def validate(record)
    if record.not_after and record.not_before
      record.errors[:base] << "Event must have a duration of at least 1 day" if not record.not_after - record.not_before >= 1.day
      record.errors[:base] << "Event cannot have a duration of more than 21 days" if record.not_after - record.not_before > 21.days
    end

    record.errors[:name] << "Event name may contain only letters, digits, and apostrophe (')" unless
      record.name.match(/^[ a-zA-Z0-9']+$/)
  end
end

class Event < ActiveRecord::Base
  serialize :status

  belongs_to :user
  has_many :attendees

  validates :not_before, :presence => true
  validates :not_after, :presence => true

  # event name may be 64 chars. but what about null terminator? use 63.
  #   see: http://www.ietf.org/rfc/rfc2459.txt
  #   ub-common-name-length INTEGER ::= 64
  validates :name, :presence => true, :length => { :within => 1..63 }
  validates :admin_password, :presence => true, :length => { :within => 6..20 }

  include ActiveModel::Validations
  validates_with EventValidator

  before_create :set_download_key, :set_registration_key

  def set_download_key
    self.download_key = generate_ascii_key
  end

  def set_registration_key
    self.registration_key = generate_ascii_key
  end

  def generate_ascii_key
    the_key = ''

    valid_set_ascii = ("A".."Z").to_a
    16.times do
      the_key << valid_set_ascii[ rand(valid_set_ascii.size-1) ]
    end

    return the_key
  end

  def paid?
    self.status == :paid
  end

  def downloadable?
    [:paid, :downloaded].include? self.status  
  end

  def downloaded?
    self.status == :downloaded
  end

  def make_users_xml
    result_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<Openfire>
"
    now = Time.now().to_i * 1000

    for attendee in self.attendees do
      username = Digest::SHA1.hexdigest( attendee.email )

      photo_u64_data = attendee.photo_data64

      result_xml += "  <User>
      <Username>#{username}</Username>
      <Password>#{attendee.passcode}</Password>
      <Email>#{attendee.email}</Email>
      <Name>#{attendee.name}</Name>
      <CreationDate>#{now}</CreationDate>
      <ModifiedDate>#{now}</ModifiedDate>
      <Roster/>
      <vCard xmlns=\"vcard-temp\">
          <VERSION>2.0</VERSION>
          <FN>#{attendee.name}</FN>
          <PHOTO>
              <TYPE>JPG</TYPE>
              <BINVAL>#{photo_u64_data}</BINVAL>
          </PHOTO>
      </vCard>
    </User>
  "
    end
    result_xml += "</Openfire>\n"

    result_xml
  end
end