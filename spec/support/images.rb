FactoryBot.define do

  factory :image1, class: Image do
    avatar { File.new(Rails.root.join('spec', 'files', 'images', '1.gif')) }
    # association :deal, factory: :deal
  end

  factory :image2, class: Image do
    avatar { File.new(Rails.root.join('spec', 'files', 'images', '2.gif')) }
    # association :deal, factory: :deal
  end

end
