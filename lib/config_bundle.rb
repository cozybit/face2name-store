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

class ConfigBundle
  attr_accessor :config_filename, :temp_dir

  def initialize(event)
    # build directory structure on disk
    @temp_dir = Utils.make_temp_dir()

    tarball_source = File.join( @temp_dir, 'to_tar_gz' )
    FileUtils.mkdir_p( tarball_source )
    raise "Assert: Unable to make temporary folder at '"+tarball_source+"'" unless File.directory? tarball_source

    # Add a 5 day buffer on either side of the certificate's window
    ConfigBundle.openssl_certificates( @temp_dir, File.join( tarball_source, 'keys' ),
      event.id, event.name, event.not_before - 5.days, event.not_after + 5.days)

    # Make admin password File
    f = File.new( File.join( tarball_source, 'admin_password.txt' ), 'wb' )
    f.write( event.admin_password )
    f.close()

    # tar/gzip it.
    tgz_filename = tar_gz( event.name, @temp_dir, tarball_source )

    # encrypt it
    @config_filename = f2n_cipher(tgz_filename )
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
    output = Utils.run_cmd( tar_gz_cmd, "Trying to tar-gzip file, but the command failed." )

    if ! File.exists? tarball_filename
      raise "Problem creating configuration bundle. tar/gzip command seemed to work, but there is no output file. COMMAND=>>>#{tar_gz_cmd}<<< OUTPUT=>>>#{output}<<<"
    end

    return tarball_filename
  end

  #
  # Make server key and CSR
  # see: {svn}/face2name/tests/openfire/extract.sh
  #
  def self.openssl_certificates( temp_dir, keys_dir, cert_serial_num, event_name, not_before, not_after )
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

    Utils.run_cmd( "openssl genrsa -out \"#{ssl_server_key}\" 1024  2>&1",
      "Server key generation failed" )

    Utils.run_cmd( "openssl req -config \"#{openssl_config}\" -new -key \"#{ssl_server_key}\" -out \"#{f2n_server_csr}\" 2>&1",
      "Server CSR generation failed" )

    File.open(File.join(temp_ca_dir, 'serial'), 'w') do |f|
      f.write( "%02x" % cert_serial_num ) # Serial file is in hex format
    end

    cmd = "openssl ca -batch -in \"#{f2n_server_csr}\" -notext -cert \"#{ssl_ca_cert}\" -keyfile \"#{ssl_ca_key}\" " +
          "-out \"#{ssl_server_cert}\" -extensions \"usr_cert\" -config \"#{openssl_config}\" 2>&1"

    Utils.run_cmd( cmd, "Certificate signing failed")

    return ssl_server_cert
  end

  def self.aes(plaintext, key)
    (aes = OpenSSL::Cipher::Cipher.new('aes-256-ecb').encrypt()).key = key # Should Digest::SHA256.digest(key)) this key instead
    aes.update(plaintext) << aes.final
  end

  def encrypt(plaintext)
    ConfigBundle.aes(plaintext, File.read(F2N[:encryption_key]))
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
    out.write(encrypt(tgz.read()))
    tgz.close()
    out.close()

    if ! File.exists? output_filename
      raise "Error signing configuration bundle"
    end

    return output_filename
  end

  def cleanup
    raise "The directory 'to_tar_gz' does not exist. Can't be an old configuration bundle temp folder."\
      unless File.exists? File.join( @temp_dir, 'to_tar_gz')
    FileUtils.rm_rf( @temp_dir )
  end
end
