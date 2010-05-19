class CreateBaseSchema < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable :null => false
#      t.confirmable
      t.recoverable
      t.rememberable
      t.trackable
      t.lockable :lock_strategy => :none, :unlock_strategy => :none
      # t.token_authenticatable
      t.timestamps

      t.string :role, :default => 'manager'
      t.boolean :is_unlimited, :default => false
    end

    add_index :users, :email,                :unique => true
#    add_index :users, :confirmation_token,   :unique => true
    add_index :users, :reset_password_token, :unique => true

    create_table :events do |t|
      t.belongs_to :user
      t.string :name
      t.datetime :not_before
      t.datetime :not_after
      t.string :admin_password

      t.timestamps
    end
  end

  def self.down
    drop_table :events
    drop_table :users
  end
end