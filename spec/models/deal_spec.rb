require "rails_helper"

RSpec.describe Deal, type: :model do

  let(:valid_deal) { FactoryBot.create(:deal, :with_images, :with_publishing_date) }
  let(:deal_without_images_and_publishing_date) { FactoryBot.create(:deal) }
  let(:built_valid_deal) { FactoryBot.build(:deal, :with_images, :with_publishing_date) }
  let(:built_deal_without_images_and_publishing_date) { FactoryBot.build(:deal) }

  context 'Modules' do
    it 'includes Presentable' do
      expect(Deal.ancestors).to include(Presentable)
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:images).dependent(:destroy) }
    it { is_expected.to have_many(:line_items).dependent(:restrict_with_error) }
  end

  it { is_expected.to accept_nested_attributes_for(:images).allow_destroy(true) }

  describe 'validations' do
    context 'title' do
      it { is_expected.to validate_presence_of(:title) }
      it { is_expected.to validate_uniqueness_of(:title).case_insensitive }
    end

    context 'description' do
      it { is_expected.to validate_presence_of(:description) }
    end

    context 'price' do
      it { is_expected.to validate_presence_of(:price) }
      it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(ENV['minimum_price'].to_f) }
    end

    context 'discount_price' do
      it { is_expected.to validate_presence_of(:discount_price) }
      it { is_expected.to validate_numericality_of(:discount_price).is_greater_than_or_equal_to(ENV['minimum_discount_price'].to_f) }
    end

    context 'quantity' do
      it { is_expected.to validate_presence_of(:quantity) }
      it { is_expected.to validate_numericality_of(:quantity).is_greater_than_or_equal_to(0).only_integer }
    end

    context 'custom validations' do
      context 'publishing_date_must_be_after_today' do
        it { is_expected.to callback(:publishing_date_must_be_after_today).before(:validate).if(:publishing_date_changed?) }
        
        it 'fails' do
          built_valid_deal.publishing_date = Date.current
          expect(built_valid_deal).not_to be_valid
          expect(built_valid_deal.errors[:publishing_date]).to include(I18n.t(:publishing_date_must_be_after_today, scope: [:errors, :custom_validation], date: Date.current))
        end
      end

      context 'associated_images_count' do
        it { is_expected.to callback(:associated_images_count).before(:validate).if(:has_publishing_date?) }
      
        it 'fails' do
          built_deal_without_images_and_publishing_date.publishing_date = 2.day.after
          expect(built_deal_without_images_and_publishing_date).not_to be_valid
          expect(built_deal_without_images_and_publishing_date.errors[:images]).to include(I18n.t(:image_greater_than, scope: [:errors, :custom_validation], image_count: ENV['published_deal_minimum_image_count'].to_i))
        end
      end

      context 'quantity_count' do
        it { is_expected.to callback(:quantity_count).before(:validate).if(:has_publishing_date?) }

        it 'fails' do
          built_deal_without_images_and_publishing_date.quantity = 9
          built_deal_without_images_and_publishing_date.publishing_date = 3.day.after
          expect(built_deal_without_images_and_publishing_date).not_to be_valid
          expect(built_deal_without_images_and_publishing_date.errors[:quantity]).to include(I18n.t(:quantity_greater_than, scope: [:errors, :custom_validation], quantity_count: ENV['published_deal_minimum_quantity_count'].to_i))
        end
      end

      context 'publishing_date_cannot_be_updated' do
        it { is_expected.to callback(:publishing_date_cannot_be_updated).before(:validate).if(:publishing_date_was) }
        it { is_expected.to callback(:publishing_date_cannot_be_updated).before(:validate).if(:publishing_date_changed?) }

        context 'fails' do
          it 'if live' do
            valid_deal.update_columns publishing_date: Date.current, start_at: Time.current, end_at: 1.day.after
            expect(valid_deal.update publishing_date: 3.day.after).to be false
            expect(valid_deal.errors[:publishing_date]).to include(I18n.t(:publishing_date_cannot_be_changed_for_live_deal, scope: [:errors, :custom_validation]))  
          end

          it 'if expired' do
            valid_deal.update_columns publishing_date: 1.day.before, start_at: 1.day.before, end_at: Time.current
            expect(valid_deal.update publishing_date: 3.day.after).to be false
            expect(valid_deal.errors[:publishing_date]).to include(I18n.t(:publishing_date_cannot_be_changed_after_deal_expire, scope: [:errors, :custom_validation]))  
          end

          it 'deal about to go live in 24 hours' do
            valid_deal.update_columns publishing_date: 23.hours.after, start_at: 23.hours.after, end_at: 2.day.after
            expect(valid_deal.update publishing_date: 3.day.after).to be false
            expect(valid_deal.errors[:publishing_date]).to include(I18n.t(:publishing_date_cannot_be_changed_h_hours_before_deal_goes_live, scope: [:errors, :custom_validation], h: ENV['bumber_of_hours_before_start_when_publishing_date_cannot_be_changed']))  
          end
        end
      end

      context 'maximum_number_of_deals_per_publishing_date' do
        it { is_expected.to callback(:maximum_number_of_deals_per_publishing_date).before(:validate).if(:has_publishing_date?) }

        it 'fails' do
          FactoryBot.create(:deal).update_columns(publishing_date: 3.days.after)
          FactoryBot.create(:deal, title: 'test_title2').update_columns(publishing_date: 3.days.after)
            
          built_deal_without_images_and_publishing_date.publishing_date = 3.days.after
          expect(built_deal_without_images_and_publishing_date).not_to be_valid
          expect(built_deal_without_images_and_publishing_date.errors[:publishing_date]).to include(I18n.t(:cannot_have_more_deals, scope: [:errors, :custom_validation], maximum_number_of_deals: ENV['maximum_number_of_deal_per_publishing_date'].to_i))
        end
      end

    end
  end

  describe 'callbacks' do
    context 'ensure_images_count_valid after update' do
      it { is_expected.to callback(:ensure_images_count_valid).after(:update).if(:has_publishing_date?) }
    
      it 'update fails' do
        image1 = valid_deal.images.first
        expect(valid_deal.update(images_attributes: [id: image1.id, avatar: image1.avatar, _destroy: 1])).not_to be true
      end      
    end

    context 'ensure_deal_not_live_or_expired before destroy' do
      it { is_expected.to callback(:ensure_deal_not_live_or_expired).before(:destroy) }
      
      context 'destroy fails' do
        it 'when live' do
          valid_deal.update_columns(publishing_date: Date.current, start_at: Time.current, end_at: 1.day.after)
          expect(valid_deal.destroy).to be false
        end

        it 'when expired' do
          valid_deal.update_columns(publishing_date: 1.day.before, start_at: 1.day.before, end_at: 1.second.before)
          expect(valid_deal.destroy).to be false
        end
      end
    end
  end

  describe'scopes' do
    context '.publishable_on' do
      it { expect(Deal).to respond_to(:publishable_on) }

      it 'today' do
        valid_deal.update_columns(publishing_date: 2.day.after)
        expect(Deal.publishable_on(2.day.after)).to include(valid_deal)
      end

      it 'tomorrow' do
        valid_deal.update_columns(publishing_date: Date.current)
        expect(Deal.publishable_on).to include(valid_deal)
      end
    end

    context '.live' do
      it { expect(Deal).to respond_to(:live) }

      it 'when start_at current time' do
        valid_deal.update_columns(publishing_date: Date.current, start_at: Time.current, end_at: 1.day.after)
        expect(Deal.live).to include(valid_deal)
      end

      it 'when end_at current time' do
        valid_deal.update_columns(publishing_date: 1.day.before, start_at: 1.day.before, end_at: 10.minute.after)
        expect(Deal.live).to include(valid_deal)
      end
    end

    context '.expired' do
      it { expect(Deal).to respond_to(:expired) }

      it 'when end_at current time' do
        valid_deal.update_columns(publishing_date: 1.day.before, start_at: 1.day.before, end_at: 10.minute.after)
        expect(Deal.live).to include(valid_deal)
      end
    end

    context '.future' do
      it { expect(Deal).to respond_to(:future) }

      it 'pubslished for 3 days from now' do
        valid_deal.update_columns(publishing_date: 3.day.after)
        expect(Deal.future).to include(valid_deal)
      end
    end

    context '.unpublished' do
      it { expect(Deal).to respond_to(:unpublished) }

      it 'has no publishing_date' do
        deal_without_images_and_publishing_date
        expect(Deal.unpublished).to include(deal_without_images_and_publishing_date)
      end
    end

    context '.chronologically_by_end_at' do
      it { expect(Deal).to respond_to(:chronologically_by_end_at) }
    end

    context '.chronologically_by_end_at' do
      it { expect(Deal).to respond_to(:reverse_chronologically_by_end_at) }
    end

    context '.search_by_title_and_description' do
      it { expect(Deal).to respond_to(:search_by_title_and_description) }
    end
  end

  describe 'public instance methods' do
    context '#has_publishing_date?' do
      it { is_expected.to respond_to(:has_publishing_date?) }
      
      it 'does not has publishing_date' do
        deal_without_images_and_publishing_date
        expect(deal_without_images_and_publishing_date.has_publishing_date?).to be false
      end

      it 'has_publishing_date' do
        valid_deal.update_columns publishing_date: 3.days.after
        expect(valid_deal.has_publishing_date?).to be true
      end
    end

    context '#publishability_errors' do
      it { is_expected.to respond_to(:publishability_errors) }

      it 'has invalid image count' do
        deal_without_images_and_publishing_date
        expect(deal_without_images_and_publishing_date.publishability_errors).to include('Image ' + I18n.t(:image_greater_than, scope: [:errors, :custom_validation], image_count: ENV['published_deal_minimum_image_count'].to_i))
      end

      it 'has invalid quantity count' do
        deal_without_images_and_publishing_date.update_columns quantity: 9
        expect(deal_without_images_and_publishing_date.publishability_errors).to include('Quantity ' + I18n.t(:quantity_greater_than, scope: [:errors, :custom_validation], quantity_count: ENV['published_deal_minimum_quantity_count'].to_i))
      end

      it 'has no errors' do
        expect(valid_deal.publishability_errors).to be_empty
      end
    end

    context '#is_live?' do
      it { is_expected.to respond_to(:is_live?) }

      context 'false' do
        it 'start_at is nil' do
          deal_without_images_and_publishing_date.update_columns(start_at: nil)
          expect(deal_without_images_and_publishing_date.is_live?).to be false
        end

        it 'end_at is nil' do
          deal_without_images_and_publishing_date.update_columns(end_at: nil)
          expect(deal_without_images_and_publishing_date.is_live?).to be false
          
        end

        it 'start_at > current time' do
          valid_deal.update_columns(publishing_date: Date.current, start_at: 1.hour.after, end_at: 25.hours.after)
          expect(valid_deal.is_live?).to be false
        end

        it 'end_at < current time' do
          valid_deal.update_columns(publishing_date: 1.day.before, start_at: 1.day.before, end_at: 1.second.before)
          expect(valid_deal.is_live?).to be false
        end
      end

      context 'true' do
        it 'when start_at current time' do
          valid_deal.update_columns(publishing_date: Date.current, start_at: Time.current, end_at: 1.day.after)
          expect(valid_deal.is_live?).to be true
        end

        it 'when end_at current time' do
          valid_deal.update_columns(publishing_date: 1.day.before, start_at: 1.day.before, end_at: 10.minute.after)
          expect(valid_deal.is_live?).to be true
        end
      end
    end

    context '#is_expired?' do
      it { is_expected.to respond_to(:is_expired?) }
      
      context 'false' do
        it 'start_at is nil' do
          deal_without_images_and_publishing_date.update_columns(start_at: nil)
          expect(deal_without_images_and_publishing_date.is_expired?).to be false
        end

        it 'end_at is nil' do
          deal_without_images_and_publishing_date.update_columns(end_at: nil)
          expect(deal_without_images_and_publishing_date.is_expired?).to be false
        end

        it 'end_at > current time' do
          valid_deal.update_columns(publishing_date: 1.day.before, start_at: 1.day.before, end_at: 10.minute.after)
          expect(valid_deal.is_expired?).to be false
        end
      end

      context 'true' do
        it 'end_at < current time' do
          valid_deal.update_columns(publishing_date: 1.day.before, start_at: 1.day.before, end_at: Time.current)
          expect(valid_deal.is_expired?).to be true
        end
      end
    end

    it { is_expected.to respond_to(:pretty_errors) }
  end
end
