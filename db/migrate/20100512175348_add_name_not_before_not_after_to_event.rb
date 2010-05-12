class AddNameNotBeforeNotAfterToEvent < ActiveRecord::Migration
  def self.up
    remove_column :events, :start_time
    remove_column :events, :end_time
    add_column :events, :not_before, :datetime
    add_column :events, :not_after, :datetime
    add_column :events, :admin_password, :string
  end

  def self.down
    remove_column :events, :not_after
    remove_column :events, :not_before
    remove_column :events, :admin_password
    add_column :events, :start_time, :date
    add_column :events, :end_time, :date
  end
end
