require 'test_helper'
require 'google_checkout'

class GoogleCheckoutTest < ActiveSupport::TestCase
  test 'purchase event communicates with google checkout api' do
    redirect_url = purchase_event(events(:one).id)

    # assert redirect_url != nil
  end
end