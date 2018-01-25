class AddressSerializer < ActiveModel::Serializer

  attributes :house_number, :street, :city, :state, :country, :pincode

end
