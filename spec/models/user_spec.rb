require 'rails_helper'

RSpec.describe User, type: :model do

  let!(:user) { FactoryBot.create(:user) }

  context 'Modules' do
    it 'includes Authenticable' do
      expect(User.ancestors).to include(Authenticable)
    end

    it 'includes TokenGenerator' do
      expect(User.ancestors).to include(TokenGenerator)
    end

    it 'includes Presentable' do
      expect(User.ancestors).to include(Presentable)
    end
  end

  context 'has current_password accessor' do
    it { is_expected.to respond_to(:current_password) }
    it { is_expected.to respond_to(:current_password=) }
  end

  it { is_expected.to have_secure_password }

  context 'has secure token' do
    it 'includes' do
      expect(User.ancestors).to include(ActiveRecord::SecureToken)
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:orders).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:line_items).through(:orders) }
    it { is_expected.to have_many(:payments).through(:orders) }
    it { is_expected.to have_many(:addresses).dependent(:nullify) }
  end

  describe 'validations' do
    context 'name' do
      it { is_expected.to validate_presence_of(:name) }
    end

    context 'email' do
      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
      it 'format' do
        expect(User.validators_on(:email).any? { |validator| validator.is_a?(ActiveModel::Validations::FormatValidator) && 
          validator.options == {:with=>/\A([\w.]+)@([\w]+)\.([\w&&\S^_]{2,})\z/, allow_blank: true} }).to be true
      end
    end

    context 'password' do
      it 'length' do
        expect(User.validators_on(:password).any? { |validator| validator.is_a?(ActiveRecord::Validations::LengthValidator) && 
          validator.options == {allow_blank: true, minimum: 6} }).to be true
      end

      it 'presence' do
        expect(User.validators_on(:password).any? { |validator| validator.is_a?(ActiveRecord::Validations::PresenceValidator) && 
        validator.options == {if: :password_confirmation_present?, on: :update} }).to be true
      end
    end

    context 'password_confirmation' do
      it { is_expected.to validate_presence_of(:password_confirmation).on(:create) }
    end
  end

  describe 'callbacks' do
    context 'clear_confirmed_token_sent_at' do
      it { is_expected.to callback(:clear_confirmed_token_sent_at).before(:update).if(:confirmation_token_changed?) }
      
      it 'when confirmation_token changes to nil' do
        expect(user.confirmation_token).to_not be nil
        user.confirm
        expect(user.confirmation_token).to be nil
      end
    end

    context 'clear_password_reset_token_sent_at' do
      it { is_expected.to callback(:clear_password_reset_token_sent_at).before(:update).if(:password_reset_token_changed?) }
      
      it 'when password_reset_token changes to nil' do
        user.generate_password_reset_token
        expect(user.password_reset_token).to_not be nil
        user.update(password_reset_token: nil)
        expect(user.password_reset_token).to be nil
      end
    end

    it { is_expected.to callback(:send_confirmation_instructions).after(:commit).on(:create) }
  end

  describe '#send_confirmation_instructions' do
    it 'expects to send confirmation instructions' do
      Delayed::Job.delete_all
      expect { user.send_confirmation_instructions }.to change { Delayed::Job.count }.by(1)
    end
  end

  describe '#send_password_reset_instructions' do
    it 'expects to send password reset instructions' do
      Delayed::Job.delete_all
      expect { user.send_password_reset_instructions }.to change { Delayed::Job.count }.by(1)
    end
  end

  describe '#generate_password_reset_token' do
    it 'expects to generate password reset token' do
      user.generate_password_reset_token
      expect(user.attribute_before_last_save(:password_reset_token)).not_to eq(user.password_reset_token)
    end
  end

  describe '#generate_confirmation_token' do
    it 'expects to generate confirmation token' do
      user.generate_confirmation_token
      expect(user.attribute_before_last_save(:confirmation_token)).not_to eq(user.confirmation_token)
    end
  end

  describe '#confirmation_token_expired?' do
    context 'true' do
      it 'confirmation_token_sent_at is nil' do
        user.update_columns(confirmation_token_sent_at: nil)
        expect(user.confirmation_token_expired?).to be true
      end

      it 'confirmation_token is nil' do
        user.update_columns(confirmation_token: nil)
        expect(user.confirmation_token_expired?).to be true
      end

      it 'confirmation token past validity' do
        user.update_columns(confirmation_token_sent_at: Time.current - CONFIRMATION_TOKEN_VALIDITY)
        expect(user.confirmation_token_expired?).to be true
      end
    end

    it 'expects to return false' do
      expect(user.confirmation_token_expired?).to be false
    end
  end

  describe '#password_reset_token_expired?' do
    context 'true' do
      it 'password_reset_token_sent_at is nil' do
        user.update_columns(password_reset_token_sent_at: nil)
        expect(user.password_reset_token_expired?).to be true
      end

      it 'password_reset_token is nil' do
        user.update_columns(password_reset_token: nil)
        expect(user.password_reset_token_expired?).to be true
      end

      it 'password_reset_token past validity' do
        user.update_columns(password_reset_token_sent_at: Time.current - PASSWORD_RESET_TOKEN_VALIDITY)
        expect(user.password_reset_token_expired?).to be true
      end
    end

    it 'expects to return false' do
      user.generate_password_reset_token
      expect(user.password_reset_token_expired?).to be false
    end
  end

  describe '#confirm' do
    it 'expects confirmation_token is nil' do
      user.confirm
      expect(user.confirmation_token).to be_nil
    end

    it 'expect confirmatino token' do
      user.confirm
      expect(user.confirmed_at).to be_kind_of(ActiveSupport::TimeWithZone )
      expect(user.confirmation_token_sent_at).to be nil
    end
  end

  describe 'callback execution' do
    it 'clear_password_reset_token_sent_at if password reset token changes to nil' do
      user.generate_password_reset_token
      expect(user.password_reset_token_sent_at).not_to be nil
      user.update(password_reset_token: nil)
      expect(user.password_reset_token_sent_at).to be nil
    end
  end

end
