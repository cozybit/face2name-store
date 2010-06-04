module Utils
  def self.make_temp_dir()
    shared_temp_fldr = File.join(Rails.root, 'tmp')
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
  def self.run_cmd( cmd, error_msg="Executing shell command" )
    output = %x[ #{cmd} ]  # run the command

    # check for errors
    status = $?.exitstatus
    if status != 0
      raise "#{error_msg}. COMMAND=>>>#{cmd}<<< EXIT_STATUS=#{status} OUTPUT=>>>#{output}<<<"
    end

    return output

  end
end