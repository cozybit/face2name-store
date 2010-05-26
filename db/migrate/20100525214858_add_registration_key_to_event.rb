class AddRegistrationKeyToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :registration_key, :string
  end

  def self.down
    remove_column :events, :registration_key
  end
end
