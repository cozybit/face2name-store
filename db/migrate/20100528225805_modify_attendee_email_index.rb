class ModifyAttendeeEmailIndex < ActiveRecord::Migration
  def self.up
    remove_index :attendees, [:name, :email]
    add_index :attendees, [:email, :event_id], :unique => true
  end

  def self.down
    remove_index :attendees, [:email, :event_id]
    add_index :attendees, [:name, :email], :unique => true
  end
end
