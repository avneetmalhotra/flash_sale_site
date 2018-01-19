class User < ApplicationRecord
  include Authenticable
  include TokenGenerator

  include Presentable

  attr_accessor :current_password

  has_secure_password
  has_secure_token :api_token
  has_secure_token :remember_me_token

  ## ASSOCATIONS
  has_many :orders, dependent: :restrict_with_error
  has_many :line_items, through: :orders
  has_many :addresses, dependent: :nullify

  ## VALIDATIONS
  with_options presence: true do
    validates :name
    validates :email, uniqueness: { case_sensitive: false }, format:{
      with: Regexp.new(ENV['email_regex']),
      allow_blank: true
    }

    validates :password, on: :update, if: :password_confirmation_present?
  end
  
  validates :password, allow_blank: true, length: { minimum: 6 }

  ## CALLBACKLS
  before_update :clear_confirmed_token_sent_at, if: :confirmation_token_changed?
  before_update :clear_password_reset_token_sent_at, if: :password_reset_token_changed?
  after_commit :send_confrimation_instructions, on: :create


    def send_confrimation_instructions
      generate_confirmation_token
      UserMailer.confirmation_email(id, password).deliver_later
    end

    def send_password_reset_instructions
      generate_password_reset_token
      UserMailer.password_reset_email(id).deliver_later
    end

    def generate_password_reset_token
      update_columns(password_reset_token: generate_unique_token(:password_reset_token, 16), password_reset_token_sent_at: Time.current)
    end

    def generate_confirmation_token
      update_columns(confirmation_token: generate_unique_token(:confirmation_token, 16), confirmation_token_sent_at: Time.current)
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

    def recently_used_address_id
      # orders.last is not used because it will return the current_order user is working on
      if orders.complete.present?
        recently_used_address_id = orders.complete.last.address_id
      else
        recently_used_address_id = addresses.last.try(:id)
      end
      recently_used_address_id
    end

  private

    def clear_confirmed_token_sent_at
      self.confirmation_token_sent_at = nil if confirmation_token.nil?
    end

    def clear_password_reset_token_sent_at
      self.password_reset_token_sent_at = nil if password_reset_token.nil?
    end
    
    def password_confirmation_present?
      password_confirmation.present?
    end
end
