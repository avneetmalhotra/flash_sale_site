require "rails_helper"

RSpec.describe Order, type: :model do

  let(:order) { FactoryBot.create(:order, :in_cart) }
  let(:completed_order) { FactoryBot.create(:order, :completed, user_email: 'completed_order@mail.com') }
  
  context 'Modules' do
    it 'includes TokenGenerator' do
      expect(Order.ancestors).to include(TokenGenerator)
    end

    it 'includes Checkout' do
      expect(Order.ancestors).to include(TokenGenerator)
    end

    it 'includes Presentable' do
      expect(Order.ancestors).to include(TokenGenerator)
    end
  end

  it { expect(Order.constants).to include(:VALID_STATES) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:line_items).dependent(:destroy) }
    it { is_expected.to have_many(:deals).through(:line_items)}
    it { expect(Order.reflections).to include() }
    it 'belong_to address' do
      association = Order.reflect_on_association(:address)
      expect(association.class).to eql(ActiveRecord::Reflection::BelongsToReflection)
      expect(association.options).to eql( {optional: true})
    end
    it { is_expected.to have_many(:payments).dependent(:destroy) }
  end

  describe 'validations' do
    context 'invoice_number' do
      # it { is_expected.to validate_presence_of(:invoice_number) }
      # it { is_expected.to validate_uniqueness_of(:invoice_number).allow_blank }
    end

    context 'loyalty_discount' do
      it { is_expected.to validate_numericality_of(:loyalty_discount).is_greater_than_or_equal_to(ENV['minimum_loyalty_discount'].to_i) }
    end
  
    context 'total_amount' do
      it { is_expected.to validate_numericality_of(:total_amount).is_greater_than_or_equal_to(ENV['minimum_order_total_amount'].to_i) }
    end

    context 'state' do
      it { is_expected.to validate_inclusion_of(:state).in_array(Order::VALID_STATES) }
    end
  end

  describe 'scopes' do
    it { expect(Order).to respond_to(:incomplete) }
    it { expect(Order).to respond_to(:complete) }
    it { expect(Order).to respond_to(:ready_for_delivery) }
    it { expect(Order).to respond_to(:cancelled) }
    it { expect(Order).to respond_to(:delivered) }
    it { expect(Order).to respond_to(:search_by_email) }
  end

  describe 'callbacks' do
    context 'ensure_order_incomplete before_destory' do
      it { is_expected.to callback(:ensure_order_incomplete).before(:destroy) }
      it 'destroy fails' do
        expect(completed_order.destroy).to be false
      end
    end

    context 'generate_invoice_number before_validation' do
      it { is_expected.to callback(:generate_invoice_number).before(:validation).on(:create) }
      
      it 'assigns invoice number' do
        order = Order.new
        order.valid?
        expect(order.invoice_number).not_to be nil
      end
    end
  end


  describe 'public instance methods' do
    it { is_expected.to respond_to(:pretty_errors) }

    context 'add_deal' do
      it { is_expected.to respond_to(:add_deal) }

      it 'adds new line_item' do
        deal = FactoryBot.create(:deal, :with_images)
        expect{ order.add_deal(deal, 1) }.to change { order.line_items.count }.by(1)
      end
    end

    context 'associate_address' do
      it { is_expected.to respond_to(:associate_address) }

      it 'updates address' do
        order
        address = FactoryBot.create(:address, :with_user_id, user_id: order.user.id)
        expect(order.address).to be nil
        order.associate_address(address)
        expect(order.address.class).to eql(Address)
      end
    end

    context 'total_items_quantity' do
      it { is_expected.to respond_to(:total_items_quantity) }

      it 'returns an Integer' do
        expect(order.total_items_quantity.class).to eql(Integer)
      end
    end

    context 'items_subtotal' do
      it { is_expected.to respond_to(:items_subtotal) }

      it 'return an BigDecimal' do
        expect(order.items_subtotal.class).to eql(BigDecimal)
      end
    end

    context 'total_amount_in_cents' do
      it { is_expected.to respond_to(:total_amount_in_cents) }

      it 'returns an BigDecimal' do
        expect(order.total_amount_in_cents.class).to eql(BigDecimal)
      end
    end

    context 'to_param' do
      it { is_expected.to respond_to(:to_param) }

      it 'returns invoice_number' do
        expect(order.to_param).to eql(order.invoice_number)
      end
    end
  end

end
