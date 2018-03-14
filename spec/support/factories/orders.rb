FactoryBot.define do
  
  factory :order do
    total_amount 0.0
    loyalty_discount 0.0 

    transient do
      user_email false
    end

    before(:create) do |order, evaluator|
      if evaluator.user_email.present?
        user = create :user, email: evaluator.user_email
      else 
        user = create :user
      end
      order.user = user
    end

    trait :in_cart do
      state "cart"
    end

    trait :at_address do
      state "address"
    end 
    
    trait :at_payment do
      state "payment"
    end 
    
    trait :completed do
      state "completed"
      completed_at 1.day.before
    end
    
    trait :cancelled do
      state "cancelled"
      completed_at 1.day.before
      cancelled_at 1.day.after
    end
    
    trait :delivered do
      state "delivered"
      completed_at 1.day.before
      delivered_at 1.day.after
    end

    factory :order_with_address do |order| 

      after(:create) do |order, evaluator|
        create_list(:address, 1, :with_user_id, user_id: order.user.id)
      end
    end
  end
end
