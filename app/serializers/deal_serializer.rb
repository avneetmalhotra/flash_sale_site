class DealSerializer < ActiveModel::Serializer
  
  attributes :title, :description, :price, :discount_price, :quantity, :publishing_date, :start_at, :end_at

end
