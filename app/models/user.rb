class User < ApplicationRecord
  include Authenticable
  include TokenGenerator

  attr_accessor :current_password

  has_secure_password
  has_secure_token :api_token
  has_secure_token :remember_me_token

  ## VALIDATIONS
  with_options presence: true do
    validates :name
    validates :email, uniqueness: { case_sensitive: false }, format:{
      with: Regexp.new(ENV['email_regex']),
      allow_blank: true
    }
  end
  
  validates :password, allow_blank: true, length: { minimum: 6 }

  before_update :set_confirmed_token_sent_at, if: :confirmation_token_changed?
  before_update :set_password_reset_token_sent_at, if: :password_reset_token_changed?

    def send_confrimation_instructions
      generate_confirmation_token
      UserMailer.confirmation_email(id).deliver_later
    end

    def send_password_reset_instructions
      generate_password_reset_token
      UserMailer.password_reset_email(id).deliver_later
    end

    def generate_password_reset_token
      update(password_reset_token: generate_unique_token(:password_reset_token))
    end

    def generate_confirmation_token
      update(confirmation_token: generate_unique_token(:confirmation_token))
    end

    def confirmation_token_expired?
      return true if confirmation_token_sent_at.nil? || confirmation_token.nil?
      Time.current - confirmation_token_sent_at > CONFIRMATION_TOKEN_VALIDITY
    end

    def password_reset_token_expired?
      return true if password_reset_token_sent_at.nil? || password_reset_token.nil?
      Time.current - password_reset_token_sent_at > PASSWORD_RESET_TOKEN_VALIDITY
    end

    def confirm
      update(confirmation_token: nil, confirmed_at: Time.current)
    end

  private

    def set_confirmed_token_sent_at
      if confirmation_token.present?
        self.confirmation_token_sent_at = Time.current
      else
        self.confirmation_token_sent_at = nil
      end
    end

    def set_password_reset_token_sent_at
      if password_reset_token.present?
        self.password_reset_token_sent_at = Time.current
      else
        self.password_reset_token_sent_at = nil
      end
    end
end
