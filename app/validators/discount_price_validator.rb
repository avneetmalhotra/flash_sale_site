class DiscountPriceValidator < ActiveModel::Validator

  def validate(record)
    if record.discount_price? && record.price? && record.discount_price >= record.price
      record.errors[:discount_price] << I18n.t(:discount_price_less_than_price, scope: [:errors, :custom_validation])
    end
  end
end
