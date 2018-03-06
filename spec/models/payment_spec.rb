require "rails_helper"

RSpec.describe Payment, type: :model do
  
  let!(:payment) { FactoryBot.create(:payment) }

  it { expect(payment.user).to eql(payment.order.user) }

  describe 'associations' do
    it { is_expected.to belong_to(:order) }
  end

  describe 'scopes' do
    it { expect(Payment).to respond_to(:successful) }
    it { expect(Payment.successful).to include(payment) }
    it { expect(Payment.successful.count).to eq 1 }
  end

  describe 'callbacks' do
    it { is_expected.to callback(:complete_order).after(:commit) }
  end
end
