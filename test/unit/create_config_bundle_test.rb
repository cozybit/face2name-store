# test stuff in lib folder

require 'test_helper'
require 'create_config_bundle'
require 'openssl'
require 'base64'
require 'digest/sha2'
require 'hpricot'
require 'nokogiri'

class CreateConfigBundleTest < ActiveSupport::TestCase

  # Can we extract data from the certificate? E.g.
  # openssl x509 -noout -text -in f2n_server.cert
  test "no exceptions raised" do
    event = Event.create(:name => 'My Great Conference-'+(rand(92-65)+65).chr,
                         :not_before => Time.utc(2010, 5, 10),
                         :not_after => Time.utc(2010, 5, 15),
                         :admin_password => 'simple')
    event.id = rand(100)+1

    make_configuration_bundle( event )
  end

  test 'generated certificates are valid for 5 days before and after specified event dates' do

    not_before = Time.utc(2010, 5, 10)
    not_after = Time.utc(2010, 5, 15)

    event = Event.create(:name => 'My Great Conference-'+(rand(92-65)+65).chr,
                         :not_before => not_before,
                         :not_after => not_after,
                         :admin_password => 'simple')
    event.id = rand(100)+1

    ignored, temp_dir = make_configuration_bundle( event )
    cert_name = Dir.glob(File.join(temp_dir, '**', 'f2n_server.cert')).first

    c = OpenSSL::X509::Certificate.new(File.read(cert_name))
    assert_equal( not_after + 5.days, c.not_after )
    assert_equal( not_before - 5.days, c.not_before )
  end

  test "certificate data" do
    # create certificate
    temp_dir = make_temp_dir()
    expect_start_time = Time.utc(2010, rand(12)+1, rand(28)+1 )
    event_name = 'Test Certificate Data'
    expect_end_time = expect_start_time + (rand(21)+1) * 60*60*24
    expect_serial_num = rand(100)+1
    cert_name = openssl_certificates( temp_dir, temp_dir, expect_serial_num, event_name,
       expect_start_time, expect_end_time )

    # Check end-date
    #    e.g.: "notBefore=May 11 21:24:46 2010 GMT"
    expect_output_regex = /notAfter=#{expect_end_time.strftime('%b %e')} \d+\:\d+\:\d+ #{expect_end_time.strftime('%Y')} GMT/
    cmd = "openssl x509 -inform DER -noout -enddate -in #{cert_name} 2>&1"
    output = run_cmd( cmd )
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
    assert_match( /\/CN=#{event_name}\/.+/, c.subject.to_s )
  end

  test "encrypt file with AES" do
    plaintext = 'This is the plaintext'
    encrypted = aes(plaintext, Digest::SHA256.digest('foo'))

    d = OpenSSL::Cipher::Cipher.new('aes-256-ecb').decrypt
    d.key = Digest::SHA256.digest('foo')
    decrypted = d.update(encrypted) << d.final
    
    assert decrypted == plaintext
  end

  test "PK encryption is reversible" do
    plaintext = 'This is the plaintext'

    public_key = File.read(F2N[:test_public_key])
    encrypted = pk_encrypt(plaintext, public_key)

    private_key = File.read(F2N[:test_private_key])

    private = OpenSSL::PKey::RSA.new(private_key)
    unencrypted = private.private_decrypt(encrypted)

    assert plaintext == unencrypted
  end

#  <?xml version="1.0" encoding="UTF-8"?>
#  <Openfire>
#    <User>
#      <Username>2618fa31d056c6bb01a38f7681c03250970dd77c</Username>
#      <Password>KUKWNK</Password>
#      <Email>winston@carbonfive.com</Email>
#      <Name>Winston Wolff</Name>
#      <CreationDate>1274897145000</CreationDate>
#      <ModifiedDate>1274897145000</ModifiedDate>
#      <Roster/>
#      <vCard xmlns="vcard-temp">
#          <VERSION>2.0</VERSION>
#          <FN>Winston Wolff</FN>
#          <PHOTO>
#              <TYPE>JPG</TYPE>
#              <BINVAL></BINVAL>
#          </PHOTO>
#      </vCard>
#    </User>
#    <User>
#      <Username>9d6f1825fe8016a61946948c58817f874b1dd38a</Username>
#      <Password>RLCYMB</Password>
#      <Email>garreche@gmail.com</Email>
#      <Name>Gonzalo Arreche</Name>
#      <CreationDate>1274897145000</CreationDate>
#      <ModifiedDate>1274897145000</ModifiedDate>
#      <Roster/>
#      <vCard xmlns="vcard-temp">
#          <VERSION>2.0</VERSION>
#          <FN>Gonzalo Arreche</FN>
#          <PHOTO>
#              <TYPE>JPG</TYPE>
#              <BINVAL></BINVAL>
#          </PHOTO>
#      </vCard>
#    </User>
#  </Openfire>
#
  test 'should create valid users.xml' do
    test_users = [
      Attendee.new({ :name => 'Winston Wolff', :email => 'winston@carbonfive.com' }),
      Attendee.new({ :name => 'Gonzalo Arreche', :email => 'garreche@gmail.com' })
    ]

    test_users.each do |a|
      a.set_passcode
      a.photo = File.open(Rails.root.join('test', 'fixtures', 'files', 'paperclips.jpg'), 'r')
      a.save
    end

    xml = make_users_xml(test_users)
    xml = Nokogiri::Slop(xml)

    users = xml.Openfire.User
    assert_equal 2, users.length

    winston = users[0]
    assert_equal 'Winston Wolff', winston.Name.text
    assert_equal 'winston@carbonfive.com', winston.Email.text

    assert winston.xpath('vcard:vCard', { 'vcard' => 'vcard-temp' }).length == 1
    assert winston.xpath('vcard:vCard/vcard:PHOTO/vcard:BINVAL', { 'vcard' => 'vcard-temp' }).to_s.length > 50
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
