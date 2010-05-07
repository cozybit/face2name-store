class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable :null => false
#       t.confirmable
#       t.recoverable
      t.rememberable
#       t.trackable

      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable

      t.timestamps
    end

    add_index :users, :email,                :unique => true
#    add_index :users, :confirmation_token,   :unique => true
#    add_index :users, :reset_password_token, :unique => true
    # add_index :users, :unlock_token,         :unique => true

    # Create a user    
    admin = User.create! do |u|
      u.email = 'admin@test.com'
      u.password = 'simple'
      u.password_confirmation = 'simple'
    end
    
  end

  def self.down
    drop_table :users
  end
end
