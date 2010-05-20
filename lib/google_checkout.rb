def initiate_event_purchase(event, confirmation_url)
  # Use your own merchant ID and Key, set use_sandbox to false for production
  configuration = F2N[:google_merchant_info]

  @frontend = Google4R::Checkout::Frontend.new(configuration)
  @frontend.tax_table_factory = TaxTableFactory.new

  checkout_command = @frontend.create_checkout_command

  # Adding an item to shopping cart
  checkout_command.shopping_cart.create_item do |item|
    item.name = "Face2Name Event: #{event.name}"
    item.description = "From #{event.not_before.strftime('%b %d %Y')} to #{event.not_after.strftime('%b %d %Y')}"
    item.unit_price = Money.us_dollar(100000)
    item.quantity = 1

    item.create_digital_content do |digital_content|
      digital_content.display_disposition = 'OPTIMISTIC'
      digital_content.description = 'Click on this URL to download your event configuration.'
      digital_content.url = confirmation_url
    end
  end

  response = checkout_command.send_to_google_checkout

  event.purchase_serial_number = response.serial_number
  event.status = 'UNPAID'
  event.save!


  return response
end

def check_event_purchase_status(most_recent_notification_time)
  # Use your own merchant ID and Key, set use_sandbox to false for production
  configuration = F2N[:google_merchant_info]

  @frontend = Google4R::Checkout::Frontend.new(configuration)

  history_command = @frontend.create_order_report_command(most_recent_notification_time, Time.now() + 3.days)
  csv = history_command.send_to_google_checkout
end

