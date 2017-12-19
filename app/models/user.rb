class User < ApplicationRecord
  has_secure_password
  has_secure_token :confirmation_token
  has_secure_token :api_token
  has_secure_token :password_reset_token

  ## VALIDATIONS
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format:{
    with: Regexp.new(ENV['email_regex']),
    allow_blank: true
  }
  validates :password, allow_blank: true, length: { minimum: 6 }

end