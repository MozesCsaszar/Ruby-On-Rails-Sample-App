class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX  = /[a-z][a-z_\-1-9]*@[a-z1-9]+(\.[a-z1-9]+)+/i
  validates :email, presence: true, length: { maximum: 255 }, format: {with: VALID_EMAIL_REGEX},
            uniqueness: true
  VALID_NORMAL_PSWD = /(?=.*\d.*\d)(?=.*[A-Z]).+/
  validates :password, length: {minimum: 8}, presence: true, format: {with: VALID_NORMAL_PSWD}

  has_secure_password


  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
             BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

end
