class Address < ApplicationRecord

  ## ASSOCIATIONS
  has_many :orders, dependent: :restrict_with_error
  belongs_to :user

  ## VALIDATION
  with_options presence: true do
    validates :house_number, :street, :city, :state, :country, :pincode
  end

  validates :pincode, numericality: { 
    only_integer: true,
    greater_than: 0,
    allow_blank: true }

  validates :house_number, uniqueness: { 
    scope: [:street, :city, :pincode], 
    case_sensitive: false }

  def pretty_errors
    errors.full_messages.join("<br>")
  end

  def full_address
    ("#{house_number}<br>#{street}<br>#{city}, #{state} - #{pincode}<br>#{country}").html_safe
  end
end
