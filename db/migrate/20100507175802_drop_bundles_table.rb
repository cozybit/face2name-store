class DropBundlesTable < ActiveRecord::Migration
  def self.up
    drop_table :bundles
  end

  def self.down
    raise 'This migration cannot be rolled back.'
  end
end
