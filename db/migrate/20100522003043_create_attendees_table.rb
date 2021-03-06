class CreateAttendeesTable < ActiveRecord::Migration
  def self.up
    create_table(:attendees) do |t|
      t.belongs_to :event
      t.string :email
      t.string :name
      t.string :passcode
    end

    add_index :attendees, [:name, :email], :unique => true
  end

  def self.down
    drop_table(:attendees)
  end
end
