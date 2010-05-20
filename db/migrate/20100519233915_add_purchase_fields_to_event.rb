class AddPurchaseFieldsToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :purchase_serial_number, :string
    add_column :events, :purchase_status, :string
    add_column :events, :download_key, :string
  end

  def self.down
    remove_column :events, :purchase_serial_number
    remove_column :events, :purchase_status
    remove_column :events, :download_key
  end
end
