class User < ApplicationRecord
  has_secure_password

  ## VALIDATIONS
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format:{
    with: /\A([\w.]+)@([\w]+)\.([\w&&\S^_]{2,})\z/
  }
  validates :password, allow_blank: true, length: { minimum: 6 }

end