require 'test/unit'
require 'rubygems'
require 'mechanize'
require 'time'

# See mechanize docs at:
#   http://mechanize.rubyforge.org/mechanize/
#   http://mechanize.rubyforge.org/mechanize/GUIDE_rdoc.html

STORE_URL = "http://localhost:3000"
SERVER_THINCLIENT_URL = "http://localhost:8080"
SERVER_IMPORT_URL = "http://localhost:9080"

class StoreToServerTest < Test::Unit::TestCase


  def f2n_server_is_running()
    browser = Mechanize.new
    begin
      browser.get(SERVER_THINCLIENT_URL)
      return true
    rescue StandardError=>exc
      puts "exception=#{exc}"
      return false
    end
  end

  def f2n_store_is_running()
    browser = Mechanize.new
    begin
      browser.get(STORE_URL)
      return true
    rescue StandardError=>exc
      puts "exception=#{exc}"
      return false
    end
  end
#
#  def test_f2n_server_is_running()
#    assert f2n_server_is_running(), "The face2name SERVER is not running. Related tests will be disabled."
#  end
#
#  def test_f2n_server_is_running()
#    assert f2n_store_is_running(), "The face2name STORE is not running. Related tests will be disabled."
#  end

  def test_buy_and_import_configuration()
    if ! f2n_server_is_running() || ! f2n_store_is_running()
      puts "skipping"
      return
    end

    browser = Mechanize.new

    # On login page, Sign in. Should go to welcome page.
    login_page = browser.get(STORE_URL)
    assert login_page != nil
    welcome_page = login_page.form_with( :action => "/users/sign_in") do |f|
      assert f != nil
      puts "form=#{f}"
      f["user[email]"] = "admin@test.com"
      f["user[password]"] = "simple"
    end.click_button

    # On welcome page, click on New Event
    new_event_link = welcome_page.link_with(:href => '/events/new')
    assert nil != new_event_link
    new_event_page = new_event_link.click
    assert nil != new_event_page

    # Fill in New Event form
    timestamp = Time.now().strftime('%b%d-%H:%M')
    not_before = Date.today() + rand(90)+1
    not_after = not_before + rand(21)+1
    the_event_page = new_event_page.form_with( :action=>"/events") do |f|
      assert nil != f
      f["event[name]"]="Automated Integration Cruise "+timestamp

      f["event[not_before(1i)]"]=not_before.year
      f["event[not_before(2i)]"]=not_before.mon
      f["event[not_before(3i)]"]=not_before.day

      f["event[not_after(1i)]"]=not_after.year
      f["event[not_after(2i)]"]=not_after.mon
      f["event[not_after(3i)]"]=not_after.day
      f["event[admin_password]"]="TEST_MASTER_PASS"
    end.click_button

    # Download the configuration file
    assert the_event_page != nil
    download_configuration_btn = the_event_page.link_with(:text=>"Download Configuration")
    config_file = download_configuration_btn.click
    assert config_file.body.length > 0
    config_tmp_filename = File.join( Dir.tmpdir, config_file.filename )
    File.open(config_tmp_filename, 'w') do |file|
      file.write(config_file.body)
    end


    #
    # Import configuration file to f2n server
    #
    import_page = browser.get( SERVER_IMPORT_URL )
    import_form = import_page.form_with(:action=>"/config/upload")
    import_form.file_uploads[0].file_name = config_tmp_filename
    result_json = import_form.click_button
    assert result_json.body.include?("\"success\":true")  # should return true
  end
end

if __FILE__ == $0
  require 'test/unit/ui/console/testrunner'
  Test::Unit::UI::Console::TestRunner.run(StoreToServerTest, Test::Unit::UI::VERBOSE)
end