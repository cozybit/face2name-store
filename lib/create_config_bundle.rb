require 'time'
require 'date'
require 'digest/sha2'
require 'digest/md5'
require 'tmpdir'
require 'find'
require 'fileutils'
require 'openssl'
require 'builder'
require 'base64'


#  Input:
#    users = a two dimensional array, e.g.:
#     [
#       [ {name}, {email}, {filename of photo} ],
#       ...
#     ]
#     
#   Output: Returns a string which is the XML file contents.
def make_users_xml( attendees )
  # This data comes from users, so check inputs well.
  # !!!
  result_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<Openfire>
"
  now = Time.now().to_i * 1000

  for attendee in attendees do
    username = Digest::SHA1.hexdigest( attendee.email )

    photo_u64_data = attendee.photo_data64

    result_xml += "  <User>
    <Username>#{username}</Username>
    <Password>#{attendee.passcode}</Password>
    <Email>#{attendee.email}</Email>
    <Name>#{attendee.name}</Name>
    <CreationDate>#{now}</CreationDate>
    <ModifiedDate>#{now}</ModifiedDate>
    <Roster/>
    <vCard xmlns=\"vcard-temp\">
        <VERSION>2.0</VERSION>
        <FN>#{attendee.name}</FN>
        <PHOTO>
            <TYPE>JPG</TYPE>
            <BINVAL>#{photo_u64_data}</BINVAL>
        </PHOTO>
    </vCard>
  </User>
"
  end
  result_xml += "</Openfire>\n"

  result_xml
end


def make_temp_dir()
#  shared_temp_fldr = Dir.tmpdir
  shared_temp_fldr = File.join(Rails.root, 'tmp' )
  valid_chars = ("A".."Z").to_a + ("a".."z").to_a + ("1".."9").to_a

  is_unique = false
  until is_unique
    unique_dir = 'f2n_'
    10.times do
      unique_dir << valid_chars[ rand(valid_chars.size-1) ]
    end

    full_unique_dir = File.join( shared_temp_fldr, unique_dir)
    is_unique = ! ( File.directory? full_unique_dir )
    
    # try again if the directory already exists.
    if ! is_unique
      print 'make_temp_dir:' , unique_dir,'already exists. Trying another combination.',"\n"
    end
  end # until is_unique
  
  FileUtils.mkdir_p( full_unique_dir )
  raise "Unable to make temporary folder at '"+full_unique_dir+"'" unless File.directory? full_unique_dir
  
  return full_unique_dir
end


# Runs a shell script, and returns: [output]
# Raises an error if the command returned a non-zero exit status.
def run_cmd( cmd, error_msg="Executing shell command" )
  output = %x[ #{cmd} ]  # run the command
  
  # check for errors
  status = $?.exitstatus
  if status != 0
    raise "#{error_msg}. COMMAND=>>>#{cmd}<<< EXIT_STATUS=#{status} OUTPUT=>>>#{output}<<<"
  end

  return output

end

def tar_gz( event_name, output_dir, tarball_source )
  # Create filename
  event_name_cleaned = event_name.gsub(/\W/,'_').slice(0,40)  # ~20 chars for date and extension. Limit to 64?
  date_str = Date.today.strftime("%Y-%m-%d")
  tarball_filename = File.join( output_dir, "#{event_name_cleaned}-#{date_str}.tar.gz" )


  # Make list of files to import
  filenames_to_tar = File.join( output_dir, "filenames_to_tar.txt" )
  f = File.new( filenames_to_tar, 'w' )
  Find.find( tarball_source ) do |path|
    if ! File.directory? path # skip any folders.
      path[0..tarball_source.size] = ""  # trim off the folder name
      f.write( path +"\n")
    end
  end
  f.close()
  
  # compose command line to run
  tar_gz_cmd = "tar -czf \"#{tarball_filename}\" -C \"#{tarball_source}\" -T #{filenames_to_tar} 2>&1" # 2>&1 will capture stderr
  output = run_cmd( tar_gz_cmd, "Trying to tar-gzip file, but the command failed." )

  if ! File.exists? tarball_filename
    raise "Problem creating configuration bundle. tar/gzip command seemed to work, but there is no output file. COMMAND=>>>#{tar_gz_cmd}<<< OUTPUT=>>>#{output}<<<"
  end
  
  return tarball_filename
end

#
# Make server key and CSR
# see: {svn}/face2name/tests/openfire/extract.sh
#
def openssl_certificates( temp_dir, keys_dir, cert_serial_num, event_name, not_before, not_after )
  #  raise "not_before should be a Time object but is #{not_before.class.name}."\
  #    unless not_before.respond_to? Time
  #  raise "not_after should be a Time object but is #{not_after.class.name}." \
  #    unless not_after.instance_of? Time

  # output files:
  ssl_server_cert = File.join(keys_dir, "f2n_server.cert")
  ssl_server_key  = File.join(keys_dir, "f2n_server.key")
  f2n_server_csr  = File.join(keys_dir, "f2n_server.csr")

  # temporary files:
  f2n_server_csr  = File.join(temp_dir, "f2n_server.csr")
  openssl_config  = File.join(temp_dir, "openssl.cnf")

  # input files needed:
  # ssl_ca_cert and ssl_ca_key should be the same files used to configure your server, i.e. passed to "extract.sh"
  ssl_ca_cert = File.join(F2N[:ca_cert])
  ssl_ca_key =  File.join(F2N[:ca_key])
  ssl_config_template = File.join(F2N[:openssl_conf_tmpl])

  # Check needed input files are there
  for f in [ssl_config_template, ssl_ca_cert, ssl_ca_key]
    if ! File.exists?( f )
      raise "Could not find required file to generate event certificate: '#{f}'"
    end
  end

  # create 'keys' folder if needed
  if ! File.exists? keys_dir
    FileUtils.mkdir( keys_dir )
  end

  # compute_subject_alt_name
  subject_alt_name = Digest::SHA1.hexdigest( event_name )+'.sha1.f2n-server-cert.face2name.local'

  temp_ca_dir = File.join( temp_dir, 'tmpCA' )
  [ temp_ca_dir, File.join( temp_ca_dir, 'newcerts'), File.join( temp_ca_dir, 'ca')].each do |dirname|
    FileUtils.mkdir( dirname )
  end
  FileUtils.touch( File.join( temp_ca_dir, 'index' ) )

  # modify ssl config template
  config = File.open( ssl_config_template, 'r' ).read()
  config.gsub!( '@TMP_DIR@', temp_ca_dir )
  config.gsub!( '@SUBJECT_ALT_ENABLED@', "" )
  config.gsub!( '@SUBJECT_ALT_NAME@', subject_alt_name )
  config.gsub!( '@CN@', event_name )
  config.gsub!( '@START_DATE@', not_before.strftime('%y%m%d000000Z') )
  config.gsub!( '@END_DATE@', not_after.strftime('%y%m%d000000Z') )
  f = File.new( openssl_config, 'w' )
  f.write( config )
  f.close()

  run_cmd( "openssl genrsa -out \"#{ssl_server_key}\" 1024  2>&1",
    "Server key generation failed" )

  run_cmd( "openssl req -config \"#{openssl_config}\" -new -key \"#{ssl_server_key}\" -out \"#{f2n_server_csr}\" 2>&1",
    "Server CSR generation failed" )

  # Sign server cert
#  days = ((not_after - Time.now()) / (60*60*24)).ceil # Convert seconds to days
#  cmd = "openssl x509 -req -extfile \"#{openssl_config}\" -extensions \"usr_cert\" "+
#      "-in \"#{f2n_server_csr}\" -CA \"#{ssl_ca_cert}\" -CAkey \"#{ssl_ca_key}\" "+
#      "-out \"#{ssl_server_cert}\" -days #{days} -CAcreateserial "+
#      "-set_serial #{cert_serial_num} 2>&1"

#      "-set_serial #{cert_serial_num} 2>&1"

  File.open(File.join(temp_ca_dir, 'serial'), 'w') do |f|
    f.write( "%02x" % cert_serial_num ) # Serial file is in hex format
  end
  
  cmd = "openssl ca -batch -in \"#{f2n_server_csr}\" -notext -cert \"#{ssl_ca_cert}\" -keyfile \"#{ssl_ca_key}\" " +
        "-out \"#{ssl_server_cert}\" -extensions \"usr_cert\" -config \"#{openssl_config}\" 2>&1"

  run_cmd( cmd, "Certificate signing failed")

  # convert encryption to DER
#  cmd = "openssl x509 -in \"#{ssl_server_cert}.pem\" -inform PEM -out \"#{ssl_server_cert}\" -outform DER"
#  run_cmd( cmd, "Certificate conversion to DER format failed.")

  return ssl_server_cert
end

def aes(plaintext, key)
  (aes = OpenSSL::Cipher::Cipher.new('aes-256-ecb').encrypt()).key = key # Should Digest::SHA256.digest(key)) this key instead
  aes.update(plaintext) << aes.final
end

def crypt(plaintext)
  aes(plaintext, File.read(F2N[:encryption_key]))
end

#
# encrypt file to be decrypted by f2n server
#
def f2n_cipher(filename)
  # replace .tar.gz with .f2nconfig
  output_filename = filename
  tar_gz = '.tar.gz'
  if output_filename.end_with? tar_gz
    output_filename = output_filename.slice(0,output_filename.length-tar_gz.length)
  end
  output_filename += '.f2nconfig'

  tgz = File.open(filename, 'r')
  out = File.open(output_filename, 'w')
  out.write(crypt(tgz.read()))
  tgz.close()
  out.close()

  if ! File.exists? output_filename
    raise "Error signing configuration bundle"
  end

  return output_filename
end


def make_configuration_bundle( event )
  # build directory structure on disk
  tempdir = make_temp_dir()
  tarball_source = File.join( tempdir, 'to_tar_gz' )
  FileUtils.mkdir_p( tarball_source )
  raise "Assert: Unable to make temporary folder at '"+tarball_source+"'" unless File.directory? tarball_source

  # Add a 5 day buffer on either side of the certificate's window
  openssl_certificates( tempdir, File.join( tarball_source, 'keys' ),
    event.id, event.name, event.not_before - 5.days, event.not_after + 5.days)

  # Make admin password File
  f = File.new( File.join( tarball_source, 'admin_password.txt' ), 'wb' )
  f.write( event.admin_password )
  f.close()

  # tar/gzip it.
  tgz_filename = tar_gz( event.name, tempdir, tarball_source )

  # encrypt it
  cipher_filename = f2n_cipher(tgz_filename )

  return [cipher_filename, tempdir]
end

def cleanup( tempdir )
  raise "The directory 'to_tar_gz' does not exist. Can't be an old configuration bundle temp folder."\
    unless File.exists? File.join( tempdir, 'to_tar_gz')
  FileUtils.rm_rf( tempdir )
end
