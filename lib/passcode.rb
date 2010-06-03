module Passcode
  # Generate a random activation code, appended with a checksum.
  # See (subversion)/face2name/tests/activation/gen_activation_code.py
  def self.make_passcode()
    act_code = ''
    valid_set_ascii = ("A".."Z").to_a

    5.times do
      act_code << valid_set_ascii[ rand(valid_set_ascii.size-1) ]
    end

    check_code = act_code.sum % valid_set_ascii.size + 65
    act_code += check_code.chr
    raise 'Assert: code should be 6 chars' unless act_code.length == 6

    return act_code
  end
end