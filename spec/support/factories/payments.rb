FactoryBot.define do
  
  factory :payment do
    charge_id "ch_1BvfS2JYOX6oeVtqZKeTaExH"
    amount 34.20
    currency "usd"
    failure_code nil
    status "succeeded"

    order
  end
end
