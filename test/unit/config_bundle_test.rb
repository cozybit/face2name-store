# test stuff in lib folder

require 'test_helper'
require 'config_bundle'
require 'openssl'
require 'base64'
require 'digest/sha2'
require 'nokogiri'

class ConfigBundleTest < ActiveSupport::TestCase

  # Can we extract data from the certificate? E.g.
  # openssl x509 -noout -text -in f2n_server.cert
  test "no exceptions raised" do
    event = Event.create(:name => 'My Great Conference-'+(rand(92-65)+65).chr,
                         :not_before => Time.utc(2010, 5, 10),
                         :not_after => Time.utc(2010, 5, 15),
                         :admin_password => 'simple')
    event.id = rand(100)+1

    ConfigBundle.new( event )
  end

  test 'config bundle should be named properly' do
    #                              123456789-123456789-123456789-123456789-123456789-123456789-123
    event = Event.create(:name => 'A Long Conference Title should be truncated from 63 to 40 chars'+(rand(92-65)+65).chr,
                         :not_before => Time.now + 1.days,
                         :not_after => Time.now + 3.days,
                         :admin_password => 'simple')

    bundle = ConfigBundle.new( event )
    assert File.basename(bundle.config_filename).start_with? 'A_Long_Con', "should begin with event name"
    timestamp = Time.now.strftime('%Y-%m-%d')
    assert bundle.config_filename.end_with? "#{timestamp}.f2nconfig"

  end

  test 'generated certificates are valid for 5 days before and after specified event dates' do

    not_before = Time.utc(2010, 5, 10)
    not_after = Time.utc(2010, 5, 15)

    event = Event.create(:name => 'My Great Conference-'+(rand(92-65)+65).chr,
                         :not_before => not_before,
                         :not_after => not_after,
                         :admin_password => 'simple')
    event.id = rand(100)+1

    bundle = ConfigBundle.new( event )
    cert_name = Dir.glob(File.join(bundle.temp_dir, '**', 'f2n_server.cert')).first

    c = OpenSSL::X509::Certificate.new(File.read(cert_name))
    assert_equal( not_after + 5.days, c.not_after )
    assert_equal( not_before - 5.days, c.not_before )
  end

  test "certificate data" do
    # create certificate
    temp_dir = Utils.make_temp_dir()
    expect_start_time = Time.utc(2010, rand(12)+1, rand(28)+1 )
    event_name = 'Test Certificate Data'
    expect_end_time = expect_start_time + (rand(21)+1) * 60*60*24
    expect_serial_num = rand(100)+1
    cert_name = ConfigBundle.openssl_certificates( temp_dir, temp_dir, expect_serial_num, event_name,
       expect_start_time, expect_end_time )

    # Check end-date
    #    e.g.: "notBefore=May 11 21:24:46 2010 GMT"
    expect_output_regex = /notAfter=#{expect_end_time.strftime('%b %e')} \d+\:\d+\:\d+ #{expect_end_time.strftime('%Y')} GMT/
    cmd = "openssl x509 -noout -enddate -in #{cert_name} 2>&1"
    output = Utils.run_cmd( cmd )
    assert_match(expect_output_regex, output )

    # Check again with Ruby lib
    c = OpenSSL::X509::Certificate.new(File.read(cert_name))
    
    assert_equal( expect_start_time.year, c.not_before.year )
    assert_equal( expect_start_time.month, c.not_before.month )
    assert_equal( expect_start_time.day, c.not_before.day )
    
    assert_equal( expect_end_time.year, c.not_after.year )
    assert_equal( expect_end_time.month, c.not_after.month )
    assert_equal( expect_end_time.day, c.not_after.day )
    assert_equal( expect_serial_num, c.serial )


    # check subject
    assert_match( /CN=#{event_name}/, c.subject.to_s )
#    assert_match( /emailAddress=ca@cozynets.com/, c.subject.to_s )

  end

  test "encrypt file with AES" do
    plaintext = 'This is the plaintext'
    encrypted = ConfigBundle.aes(plaintext, Digest::SHA256.digest('foo'))

    d = OpenSSL::Cipher::Cipher.new('aes-128-ecb').decrypt
    d.key = Digest::SHA256.digest('foo')
    decrypted = d.update(encrypted) << d.final
    
    assert decrypted == plaintext
  end

  test 'f2n_server.cert should be in tarball once' do
    event = Event.create(:name => 'tarball file list test',
                         :not_before => Time.now + 1.days,
                         :not_after => Time.now + 3.days,
                         :admin_password => 'simple')
    bundle = ConfigBundle.new( event )
    tarball_fname = bundle.config_filename.gsub('f2nconfig', 'tar.gz')

    files_in_tar = %x[tar -tf #{tarball_fname}]
    assert_equal 1, files_in_tar.scan('keys/f2n_server.cert').length
  end

  test 'ConfigBundle cleanup removes temporary directory' do
    bundle = ConfigBundle.new(events(:one))

    assert File.exist?(bundle.temp_dir)

    bundle.cleanup

    assert !File.exist?(bundle.temp_dir)
  end

#  test 'crypt file AES key and decrypt with f2n_cipher' do
#    plaintext = 'This is the plaintext'
#    encrypted = crypt(plaintext)
#
#    f = File.open('test.crypted', 'w')
#    f.write(encrypted)
#    f.close()
#
#    working = File.expand_path(File.dirname(f.path))
#
#    crypted_file = File.expand_path(f.path)
#    output_file = File.join(working, 'test.plaintext')
#
#    cipher_tool_path = F2N[:f2n_cipher_root]
#    jar = File.join(cipher_tool_path, "f2n-cipher-1.0.0.jar")
#    privk = File.join(cipher_tool_path, 'keys', 'f2n_config_bundle.key' )
#
#    cmd = "cd #{cipher_tool_path}; java -jar #{jar} -d #{crypted_file} -R #{output_file} -P #{privk}"
#    run_cmd( cmd, "Trying to decrypt the test file." )
#
#    unencrypted = File.open(output_file).read
#
#    File.delete(crypted_file)
#    File.delete(output_file)
#
#    assert plaintext == unencrypted, 'Unencrypted data does not match plaintext'
#  end

end
