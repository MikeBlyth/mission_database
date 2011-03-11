# == Schema Information
# Schema version: 20110310144121
#
# Table name: users
#
#  id                    :integer(4)      not null, primary key
#  name                  :string(255)
#  email                 :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  encrypted_password    :string(255)
#  salt                  :string(255)
#  admin                 :boolean(1)
#  encrypted_db_password :string(255)
#  medical               :boolean(1)
#  personnel             :boolean(1)
#  travel                :boolean(1)
#  member                :boolean(1)
#  immigration           :boolean(1)
#  asst_personnel        :boolean(1)
#

class User < ActiveRecord::Base
  attr_accessor :password, :password_confirmation
  attr_accessible :name, :email, :password, :password_confirmation

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name,  :presence => true,
                    :length   => { :maximum => 50 },
                    :uniqueness => { :case_sensitive => false }
                                        
  validates :email, :presence => true,
                    :format   => { :with => email_regex }

  # Automatically creates the virtual attribute 'password_confirmation'.
  validates :password, :presence     => true,
                      :confirmation => true,
                      :length       => { :within => 6..40 }
#                      :on => :create
                      
  # Custom validations for password
  validate :validate_password

  before_validation :insert_dummy_password_if_blank                     
  before_save :encrypt_password
  before_destroy :do_not_delete_last_admin
  
  def do_not_delete_last_admin
    if User.find_all_by_admin(true) == [self]
      errors[:delete] << 'Cannot delete last administrator' 
      return false
    end
    return true
  end  

  # How to allow updates to work when the password fields are blank (meaning password does not change)
  def insert_dummy_password_if_blank
    # if the fields are blank AND the record exists... (use find rather than new_record to be SURE)
    if password.blank? && password_confirmation.blank? && id && User.find(id)
      self.password = DUMMY_PASSWORD
      self.password_confirmation = password
    end
  end

  def validate_password
    errors.add('password','cannot contain your name') if password =~ Regexp.new(name, true)
    errors.add('password','cannot contain your email address') if password =~ Regexp.new(email, true)
    errors.add('password','cannot contain your email address') if email =~ Regexp.new(password, true)
    errors.add('password','cannot contain repeated characters') if password =~ /(\w)\1\1/
    errors.add('password','cannot contain only numbers') if password =~ /\A[0-9]*\Z/
  end

  # Return true if the user's password matches the submitted password.
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def self.authenticate(name, submitted_password)
    user = find_by_name(name)
    return nil  if user.nil?
    return user if user.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

  private
    DUMMY_PASSWORD = Digest::SHA2.hexdigest('C+r+z*y#38729221')[0..30]
    
    def encrypt_password
      return if password == DUMMY_PASSWORD
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
