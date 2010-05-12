class Event < ActiveRecord::Base
  validates :name, :presence => true, :length => { :within => 1..50 }
  validates :admin_password, :presence => true, :length => { :within => 6..20 }
end
