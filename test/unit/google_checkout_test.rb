require 'test_helper'
require 'google_checkout'
require 'time'

class GoogleCheckoutTest < ActiveSupport::TestCase
  test 'purchase event communicates with google checkout api' do
    response = initiate_event_purchase(events(:one), 'http://localhost:3000/foo')

    assert response.redirect_url != nil
    assert response.serial_number != nil
  end

  test 'purchase confirmation arrives from google' do 
    # purchase_response = initiate_event_purchase(events(:one))

    response = check_event_purchase_status(Time.now() - 1.day)
    puts response.split("\n")

    assert response != nil
  end
end

