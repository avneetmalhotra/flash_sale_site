class Address < ApplicationRecord

  ## ASSOCIATIONS
  has_many :orders, dependent: :nullify
  belongs_to :user

  ## VALIDATION
  with_options presence: true do
    validates :house_number, :street, :city, :state, :country, :pincode
  end

  validates :pincode, numericality: { 
    only_integer: true,
    allow_blank: true }


  def pretty_errors
    errors.full_messages.join("<br>")
  end

  private

    def full_address
      ("#{house_number}<br>#{street}<br>#{city}, #{state} - #{pincode}<br>#{country}").html_safe
    end
end
