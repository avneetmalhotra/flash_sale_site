class User < ApplicationRecord
  has_secure_password
  has_secure_token :confirmation_token
  has_secure_token :api_token
  has_secure_token :password_reset_token
  has_secure_token :remember_me_token

  ## VALIDATIONS
  with_options presence: true do
    validates :name, :email
  end
  validates :email, allow_blank: true, uniqueness: { case_sensitive: false }
  validates :email, format:{
    with: Regexp.new(ENV['email_regex']),
    allow_blank: true
  }
  validates :password, allow_blank: true, length: { minimum: 6 }

    def send_confrimation_instructions
      debugger
      UserMailer.confirmation(self).deliver_now
    end
end