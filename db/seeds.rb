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
admin.role = 'admin'
# admin.confirmed_at = DateTime.now()
admin.save!

# This user can create configurations without paying.
unlimited = User.create(
    :email => 'unlimited@test.com',
    :password => 'simple',
    :password_confirmation => 'simple',
)
unlimited.is_unlimited = true # not mass-assignable.
unlimited.save!
