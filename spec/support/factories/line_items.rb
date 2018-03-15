FactoryBot.define do
  
  factory :line_item do
    quantity 1
    discount_price 34.20
    price 123.20

    deal
    association :order, factory: :order

    trait :with_deal_id do
      deal_id nil
      association :order, factory: :order, user_email: 'new_mail@line_item2.com'
    end

  end
end
