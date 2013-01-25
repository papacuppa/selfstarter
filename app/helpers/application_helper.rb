module ApplicationHelper
 # Displays a textual representation of +number+ in british pound  
format (i.e.:
  # "£1,359.56").
  def number_to_currency_gbp (number)
    number_to_currency(number, { :unit => "&pound;"})
  end
end
