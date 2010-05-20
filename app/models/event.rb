class EventValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:not_after] << "Event must have a duration of at least 1 day" if not record.not_after - record.not_before >= 1.day
  end
end

class Event < ActiveRecord::Base
  belongs_to :user

  validates :not_before, :presence => true
  validates :not_after, :presence => true
  validates :name, :presence => true, :length => { :within => 1..50 }
  validates :admin_password, :presence => true, :length => { :within => 6..20 }

  include ActiveModel::Validations
  validates_with EventValidator

  before_create :set_download_key

  def set_download_key
    the_key = ''

    valid_set_ascii = ("A".."Z").to_a
    16.times do
      the_key << valid_set_ascii[ rand(valid_set_ascii.size-1) ]
    end

    self.download_key = the_key
  end

  def purchased?
    self.purchase_status == 'PAID'
  end
end