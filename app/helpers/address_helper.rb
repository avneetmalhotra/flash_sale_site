module AddressHelper

  def full_address
    ("#{house_number}<br>#{street}<br>#{city}, #{state} - #{pincode}<br>#{country}").html_safe
  end
end
