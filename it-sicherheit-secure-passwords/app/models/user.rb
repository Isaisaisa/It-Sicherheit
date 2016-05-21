class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates(:name, presence: true, length: { maximum: 75 })
  #validates(:email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false })

  validate do
    check_mail_correctness(email)
  end

  validate do
    check_mail_correctness_with_nil(future_email)
  end

  has_secure_password
  validates(:password, presence: true, length: { minimum: 6 }, allow_nil: true)

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_email
    #UserMailer.account_activation(self).deliver_now
  end

  def send_password_reset_email
    #UserMailer.password_reset(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def password_reset_expired?
    # equals: reset_sent_at < Time.zone.now - 30.minutes
    reset_sent_at < 30.minutes.ago
  end

  def activation_expired?
    activation_sent_at < 10.seconds.ago
  end

  private

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_sent_at = Time.zone.now
    self.activation_digest = User.digest(activation_token)
  end

  def check_mail_correctness(email_to_check)

    if email_to_check.length >=255
      errors.add(:email, "Email is too long")
    elsif (VALID_EMAIL_REGEX =~ email_to_check).nil?
      errors.add(:email, "Incorrect Emailformat")
    elsif !User.find_by(email: email_to_check).nil? || !User.find_by(future_email: email_to_check).nil?
      errors.add(:email, "Email already in use")
    end
  end

  def check_mail_correctness_with_nil(email_to_check)
    unless email_to_check.nil?
      check_mail_correctness(email_to_check)
    end
  end

end
