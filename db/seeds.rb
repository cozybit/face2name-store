require 'date'
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

  # Create a user
admin = User.create(
    :email => 'admin@test.com',
    :password => 'simple',
    :password_confirmation => 'simple'
)

admin.confirmed_at = DateTime.now()
admin.save!
