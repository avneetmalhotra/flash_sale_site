class User < ApplicationRecord
  has_secure_password
  has_secure_token :confirmation_token
  has_secure_token :api_token
  has_secure_token :password_reset_token
  has_secure_token :remember_me_token

  ## VALIDATIONS
  with_options presence: true do
    validates :name
    validates :email, uniqueness: { case_sensitive: false }
  end
  validates :email, format:{
    with: Regexp.new(ENV['email_regex']),
    allow_blank: true
  }
  validates :password, allow_blank: true, length: { minimum: 6 }

  after_commit :set_confirmed_token_sent_at, on: :create
  after_commit :send_confrimation_instructions, on: :create


    def send_confrimation_instructions
      UserMailer.confirmation_email(id).deliver_later
    end

  private

    def set_confirmed_token_sent_at
      update_columns(confirmation_token_sent_at: Time.current) 
    end
end
