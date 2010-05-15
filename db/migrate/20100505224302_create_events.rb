class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name
      t.date :not_before
      t.date :not_after
      t.string :admin_password

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
