class CreateBundles < ActiveRecord::Migration
  def self.up
    create_table :bundles do |t|
      t.string :name
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end

  def self.down
    drop_table :bundles
  end
end
