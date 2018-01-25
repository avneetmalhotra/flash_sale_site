class LineItemSerializer < ActiveModel::Serializer

  attributes :quantity, :discount_price, :price, :loyalty_discount, :total_amount, :deal

  belongs_to :deal

  def deal
    @object.deal.attributes.slice('title', 'description', 'price', 'discount_price', 'quantity', 'publishing_date', 'start_at', 'end_at')
  end

end
