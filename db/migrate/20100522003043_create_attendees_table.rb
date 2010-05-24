class CreateAttendeesTable < ActiveRecord::Migration
  def self.up
    create_table(:attendees) do |t|
      t.string :email
      t.string :name
      t.string :activation_code
    end

    add_index :attendees, [:name, :email], :unique => true
  end

  def self.down
    drop_table(:attendees)
  end
end
