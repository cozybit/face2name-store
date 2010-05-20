class RenamePurchaseStatusToStatus < ActiveRecord::Migration
  def self.up
    rename_column(:events, :purchase_status, :status)
  end

  def self.down
    rename_column(:events, :status, :purchase_status)
  end
end
