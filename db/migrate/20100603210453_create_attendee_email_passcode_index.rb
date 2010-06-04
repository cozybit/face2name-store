class CreateAttendeeEmailPasscodeIndex < ActiveRecord::Migration
  def self.up
    add_index :attendees, [:email, :passcode], :unique => true
  end

  def self.down
    remove_index :attendees, [:email, :passcode]
  end
end
