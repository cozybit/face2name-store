require "google4r/checkout"

def purchase_event(event_id)
  # Use your own merchant ID and Key, set use_sandbox to false for production
  configuration = { :merchant_id => '1234567890987654', :merchant_key => 'abc_efghijklmn_opq', :use_sandbox => true }

  @frontend = Google4R::Checkout::Frontend.new(configuration)
  @frontend.tax_table_factory = TaxTableFactory.new

  checkout_command = @frontend.create_checkout_command

  # Adding an item to shopping cart
  checkout_command.shopping_cart.create_item do |item|
    item.name = "Face2Name Event"
    item.description = "A pack of highly nutritious..."
    item.unit_price = Money.new(1000, "USD") # $35.00
    item.quantity = 1
  end

  # Create a flat rate shipping method
#  checkout_command.create_shipping_method(Google4R::Checkout::FlatRateShipping) do |shipping_method|
#    shipping_method.name = ""
#    shipping_method.price = Money.new(500, "USD")
#    # Restrict to ship only to California
#    shipping_method.create_allowed_area(Google4R::Checkout::UsStateArea) do |area|
#      area.state = "CA"
#    end
#  end

  response = checkout_command.send_to_google_checkout
  puts response.redirect_url
end

class TaxTableFactory
  def effective_tax_tables_at(time)
    tax_free_table = Google4R::Checkout::TaxTable.new(false)
    tax_free_table.name = "default table"
    tax_free_table.create_rule do |rule|
      rule.area = Google4R::Checkout::UsCountryArea.new(Google4R::Checkout::UsCountryArea::ALL)
      rule.rate = 0.0
    end
    [ tax_free_table ]
  end
end