require "rails_helper"

RSpec.describe Address, type: :model do
  
  describe 'associations' do
    it { is_expected.to have_many(:orders).dependent(:restrict_with_error) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    context 'house_number' do
      it { is_expected.to validate_presence_of(:house_number) }
      it { is_expected.to validate_uniqueness_of(:house_number).scoped_to(:street, :city, :pincode) }
    end
    
    context 'street' do
      it { is_expected.to validate_presence_of(:street) }
    end
    
    context 'city' do
      it { is_expected.to validate_presence_of(:city) }
    end
    
    context 'state' do
      it { is_expected.to validate_presence_of(:state) }
    end
    
    context 'country' do
      it { is_expected.to validate_presence_of(:country) }
    end
    
    context 'pincode' do
      it { is_expected.to validate_presence_of(:pincode) }
      it { is_expected.to validate_numericality_of(:pincode).only_integer.allow_nil }
    end

    describe 'public instance methods' do
      context '#pretty_errors' do
        it { is_expected.to respond_to(:pretty_errors) }
      end

      context '#full_address' do
        it { is_expected.to respond_to(:full_address) }
      end
    end
  end
end
