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