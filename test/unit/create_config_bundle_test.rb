# test stuff in lib folder

require 'test_helper'
require 'create_config_bundle'
require 'openssl'

class CreateConfigBundleTest < ActiveSupport::TestCase

  # Can we extract data from the certificate? E.g.
  # openssl x509 -noout -text -in f2n_server.cert
  test "no exceptions raised" do
    attendees = [
      # Name, email, photo_filename
      ["Arthur Capuano", "user_000@test.com", 'arthur_photo.jpg'],
      ["Jane Tester", "jane@doggiedoo.com", 'jane_photo.jpg'],
      ["Jill Tester", "jill@hill.com", nil],
    ]
  
    event_name = 'My Great Conference-'+(rand(92-65)+65).chr  # add something to change the filename
    config_bundle_filename, tempdir = make_configuration_bundle( event_name,
      attendees,
      'simple',
      Time.utc(2010, 5, 10),
      Time.utc(2010, 5, 15) )
#???
#    puts "Test configuration bundle is in: #{config_bundle_filename}"
  end

  test "certificate data" do

    # create certificate
    temp_dir = make_temp_dir()
    start_time = Time.utc(2010, rand(12)+1, rand(28)+1 )
    event_name = 'Test Certificate Data'
    expect_end_time = start_time + (rand(21)+1) * 60*60*24
    cert_name = openssl_certificates( temp_dir, temp_dir, event_name,
       start_time, expect_end_time )

    # Check end-date
    #    e.g.: "notBefore=May 11 21:24:46 2010 GMT"
    expect_output_regex = /notAfter=#{expect_end_time.strftime('%b %e')} \d+\:\d+\:\d+ #{expect_end_time.strftime('%Y')} GMT/
    cmd = "openssl x509 -noout -enddate -in #{cert_name} 2>&1"
    output = run_cmd( cmd )
    assert_match(expect_output_regex, output )

    # Check again with Ruby lib
    c = OpenSSL::X509::Certificate.new(File.read(cert_name))
    
    assert_equal( expect_end_time.year, c.not_after.year )
    assert_equal( expect_end_time.month, c.not_after.month )
    assert_equal( expect_end_time.day, c.not_after.day )
    assert_match( /^\/CN=#{event_name}\/.+/, c.subject.to_s )
  end

  test "users.xml exists" do
    attendees = [
            # Name, email, photo_filename
            ["Arthur Capuano", "user_000@test.com", 'arthur_photo.jpg'],
            ["Jane Tester", "jane@doggiedoo.com", 'jane_photo.jpg'],
            ["Jill Tester", "jill@hill.com", nil],
          ]
    config_bundle_filename, temp_dir = make_configuration_bundle( "my event",
      attendees,
      'simple',
      Time.utc(2010, 5, 10),
      Time.utc(2010, 5, 15) )
    assert File.exists?(File.join( temp_dir, 'to_tar_gz','users.xml' ))
  end

  test "no users means no users.xml" do
    config_bundle_filename, temp_dir = make_configuration_bundle( "my event",
      [],
      'simple',
      Time.utc(2010, 5, 10),
      Time.utc(2010, 5, 15) )
    assert !File.exists?(File.join( temp_dir, 'to_tar_gz','users.xml' ))
  end

end
