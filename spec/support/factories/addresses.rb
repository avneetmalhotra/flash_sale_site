FactoryBot.define do
  
  factory :address do
    house_number "H111" 
    street "long_street"
    city "random"
    state "imaginary"
    country "mars"
    pincode 2222

    trait :with_user do
      user
    end

    trait :with_user_id do
      user_id nil
    end
  end

end
