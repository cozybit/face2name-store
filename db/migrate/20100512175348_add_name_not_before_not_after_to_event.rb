class AddNameNotBeforeNotAfterToEvent < ActiveRecord::Migration
  def self.up
    remove_column :events, :not_before
    remove_column :events, :not_after
    add_column :events, :not_before, :datetime
    add_column :events, :not_after, :datetime
    add_column :events, :admin_password, :string
  end

  def self.down
    remove_column :events, :not_after
    remove_column :events, :not_before
    remove_column :events, :admin_password
    add_column :events, :not_before, :date
    add_column :events, :not_after, :date
  end
end
