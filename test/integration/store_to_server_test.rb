require 'rubygems'
require 'mechanize'
require 'time'
require 'tmpdir'
require 'test_helper'

# See mechanize docs at:
#   http://mechanize.rubyforge.org/mechanize/
#   http://mechanize.rubyforge.org/mechanize/GUIDE_rdoc.html

SERVER_THINCLIENT_URL = "http://localhost:8080"
SERVER_IMPORT_URL = "http://localhost:9080"


def openStringInBrowser( htmlStr )
  tmp_filename = File.join( Dir.tmpdir, 'temp.html')
  tmp = File.open( tmp_filename, 'w')
  tmp.write( htmlStr )
  tmp.close()
  puts "!!! Error body stored here: #{tmp_filename}"
  system( "open file://#{tmp.path}" )
end

class StoreToServerTest < ActiveSupport::TestCase
#class StoreToServerTest < Test::Unit::TestCase

  def f2n_server_is_running()
    browser = Mechanize.new
    begin
      browser.get(SERVER_THINCLIENT_URL)
      return true
    rescue StandardError=>exc
      #puts "exception=#{exc}"
      return false
    end
  end


  def test_configuration_with_server()
    if ! f2n_server_is_running()
      puts "test_buy_and_import_configuration: No f2n server found at #{SERVER_THINCLIENT_URL}. Skipping test."
      return
    end

    # Make a configuration bundle
    timestamp = Time.now().strftime('%b%d %H%M')
    not_before = Date.today() + rand(90)+1
    not_after = not_before + rand(9)+1

    event = Event.create(:name => "Automated Integration Cruise "+timestamp,
                         :not_before => not_before,
                         :not_after => not_after,
                         :admin_password => 'simple')

    bundle = ConfigBundle.new( event )
    
    browser = Mechanize.new

    begin
      #
      # Import configuration file to f2n server
      #
      import_page = browser.get( SERVER_IMPORT_URL )
      import_form = import_page.form_with(:action=>"/config/upload")
      import_form.file_uploads[0].file_name = bundle.config_filename
      result_json = import_form.click_button
      assert result_json.body.include?("\"success\":true"), "result from import was: #{result_json.body}"
    rescue Mechanize::ResponseCodeError => exc
      puts "!!! test_buy_and_import_configuration: Exception body=#{exc}"
      openStringInBrowser( exc.page.body )
      throw exc
    end
  end

end


if __FILE__ == $0
  require 'test/unit/ui/console/testrunner'
  Test::Unit::UI::Console::TestRunner.run(StoreToServerTest, Test::Unit::UI::VERBOSE)
end
