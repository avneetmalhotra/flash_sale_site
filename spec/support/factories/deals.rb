FactoryBot.define do

  factory :deal do
    title 'deal_test'
    description 'Some random description'
    price 235.2
    discount_price 32.2
    quantity 23
    start_at nil
    end_at nil

    trait :with_images do
      after(:build) do |deal|
        image1 = build :image1
        image2 = build :image2
        deal.images = [image1, image2]
      end
    end

    trait :with_publishing_date do |deal|
      publishing_date 10.days.after
    end

  end

end
