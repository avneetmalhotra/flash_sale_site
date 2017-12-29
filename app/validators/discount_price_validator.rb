class DiscountPriceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << 'must be greater than discount price' if record.discount_price > value
  end
end
