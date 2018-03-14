require "rails_helper"

RSpec.describe LineItem, type: :model do
  
  let!(:line_item) { FactoryBot.create(:line_item) }
  # subject { line_item }

  it { expect(line_item.user).to eql(line_item.order.user) }

  describe 'asociations' do
    it { is_expected.to belong_to(:order) }
    it { is_expected.to belong_to(:deal) }
  end

  describe 'validations' do
    context 'quantity' do
      it { is_expected.to validate_presence_of(:quantity) }
      it { is_expected.to validate_numericality_of(:quantity).is_equal_to(ENV['maximum_number_of_deals_one_can_order'].to_i).only_integer }
    end

    context 'discount_price' do
      it { is_expected.to validate_presence_of(:discount_price) }
      it { is_expected.to validate_numericality_of(:discount_price).is_greater_than_or_equal_to(ENV['minimum_discount_price'].to_f) }
    end

    context 'price' do
      it { is_expected.to validate_presence_of(:price) }
      it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(ENV['minimum_price'].to_f) }
    end

    context 'loyalty_discount' do
      it { is_expected.to validate_presence_of(:loyalty_discount) }
      it { is_expected.to validate_numericality_of(:loyalty_discount).is_greater_than_or_equal_to(ENV['minimum_loyalty_discount'] .to_i) }
    end

    context 'total_amount' do
      it { is_expected.to validate_presence_of(:total_amount) }
    end

    context 'custom validations' do
      context 'ensure_quantity_available' do
        it { is_expected.to callback(:ensure_quantity_available).before(:validate) }
        
        it 'fails' do
          line_item.deal.update_columns(quantity: 0)
          expect(line_item).not_to be_valid
          expect(line_item.errors[:quantity]).to include(I18n.t(:quantity_less_than_or_equal_to, scope: [:errors, :custom_validation], count: line_item.deal.quantity))
        end
      end

      context 'ensure_deal_not_bought_again_in_another_order' do
        it { is_expected.to callback(:ensure_deal_not_bought_again_in_another_order).before(:validate) }
        
        it 'fails' do
          ## not working
          user = line_item.user
          second_order = FactoryBot.build(:order, :completed)
          second_line_item = FactoryBot.build(:line_item, :with_deal_id, deal_id: line_item.deal.id)
          second_order.line_items << second_line_item
          user.orders << second_order
          user.save
          expect(second_line_item).not_to be_valid
          expect(second_line_item.errors[:base]).to include(I18n.t(:deal_already_bought, scope: [:errors, :custom_validation]))
        end
      end

      context 'ensure_deal_live' do
        it { is_expected.to callback(:ensure_deal_live).before(:validate) }
        
        it 'fails' do
          line_item.deal.update_columns(publishing_date: 1.day.before, start_at: 1.day.before, end_at: 1.second.before)
          expect(line_item).not_to be_valid
          expect(line_item.errors[:base]).to include(I18n.t(:deal_expired, scope: [:errors, :custom_validation]))
        end
      end
    end
  end

  describe 'callbacks' do
    context 'update_loyalty_discount before save' do
      it { is_expected.to callback(:update_loyalty_discount).before(:save) }

      it 'succeedes' do
        user = line_item.user
        old_loyalty_discount = line_item.loyalty_discount
        second_order = FactoryBot.build(:order, :in_cart)
        user.orders << second_order
        user.save
        line_item.update(price: 2222)
        expect(line_item.loyalty_discount).not_to eql(old_loyalty_discount)
      end
    end

    context 'update_total_amount before save' do
      it { is_expected.to callback(:update_total_amount).before(:save) }

      it 'succeedes' do
        old_total_amount = line_item.total_amount
        line_item.quantity = 2
        line_item.save(validate: false)
        expect(line_item.total_amount).not_to eql(old_total_amount)
      end
    end

    context 'update_orders_total after commit' do
      it { is_expected.to callback(:update_orders_total).after(:commit).if(:order_not_deleted?) }
    end
  end

  it { is_expected.to respond_to(:pretty_errors)}
end
