class Address < ApplicationRecord
  include AddressHelper

  ## ASSOCIATIONS
  has_many :orders, dependent: :restrict_with_error
  belongs_to :user

  ## VALIDATION
  with_options presence: true do
    validates :house_number, :street, :city, :state, :country, :pincode
  end

  validates :pincode, numericality: { 
    only_integer: true,
    allow_blank: true }

  validates :house_number, uniqueness: { scope: [:street, :city, :pincode] }

  def pretty_errors
    errors.full_messages.join("<br>")
  end

end
