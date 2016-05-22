class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token, :reset_token, :email_change_token, :future_send_email, :flash_warning
  before_save   :downcase_email
  before_create :create_activation_digest
  before_validation :update_email

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates(:name, presence: true, length: { maximum: 75 })
  #validates(:email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false })
  has_secure_password
  validates(:password, presence: true, length: { minimum: 8 }, allow_nil: true)
  validates_strength_of :password, :with => :email, :level => :strong, allow_nil: true

  validate do
    check_mail_correctness(email)
  end

  validate do
    check_mail_correctness_with_nil(future_email)
  end

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

  def change_email
    update_attribute(:email, self.future_email)
    update_attribute(:email_change_digest, nil)
    update_attribute(:future_email, nil)
  end

  def send_activation_email
    self.flash_warning = UserMailer.account_activation(self).to_s
  end

  def send_password_reset_email
    self.flash_warning = UserMailer.password_reset(self).to_s
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def password_reset_expired?
    # equals: reset_sent_at < Time.zone.now - 30.minutes
    self.reset_sent_at < 30.minutes.ago
  end

  def activation_expired?
    self.activation_sent_at < 30.minutes.ago
  end

  def email_change_expired?
    self.email_change_sent_at < 30.minutes.ago
  end

  def clear_password_reset
    update_attribute(:reset_digest,  nil)
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
    found_user = User.find_by(email: email_to_check)
    if found_user.nil?
      found_user = User.find_by(future_email: email_to_check)
    end

    if email_to_check.length >=255
      errors.add(:email, "Email is too long")
    elsif (VALID_EMAIL_REGEX =~ email_to_check).nil?
      errors.add(:email, "Incorrect Emailformat")
    elsif !found_user.nil? && found_user != self
      errors.add(:email, "Email already in use")
    end
  end

  def check_mail_correctness_with_nil(email_to_check)
    unless email_to_check.nil? || email_to_check.empty?
      check_mail_correctness(email_to_check)
    end
  end

  def update_email
    if self.email != future_send_email && !future_send_email.blank?
      self.future_email = future_send_email
      self.email_change_token  = User.new_token
      self.email_change_sent_at = Time.zone.now
      self.email_change_digest = User.digest(email_change_token)
      self.flash_warning = UserMailer.email_change(self).to_s
    end
  end

end
