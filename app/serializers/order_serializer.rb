class OrderSerializer < ActiveModel::Serializer

  attributes :invoice_number, :loyalty_discount, :total_amount, :completed_at, :cancelled_at, :delivered_at

  belongs_to :address
  has_many :line_items
end
