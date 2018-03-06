FactoryBot.define do

  factory :user do
    name "user"
    email "user@mail.com"
    password 'password'
    password_confirmation 'password'

    trait :admin do
      admin true
    end

    trait :confirmed do
      confirmed_at 1.day.before
    end

    trait :active do
      active true
    end

    trait :inactive do
      active false
    end

    trait :with_confirmation_token do
      confirmation_token 'confirmation_token'
    end
  end

end
