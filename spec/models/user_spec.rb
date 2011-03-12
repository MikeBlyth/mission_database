require 'spec_helper'
 
def set_password(user, password, confirmation=nil)
  user.password = password
  user.password_confirmation = confirmation || password
  user
end  

describe User do

  before(:each) do
    @attr = { :name => "Example User", 
              :email => "user@example.com",
              :password => "foobar",
              :password_confirmation => "foobar"
               }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end
  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end
  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end
  it "should reject duplicate user names (case insensitive)" do
    User.create!(@attr)
    # make a user with the same name (but upper case), and a different email
    user_with_duplicate_name = User.new(@attr)
    user_with_duplicate_name.name.upcase!
    user_with_duplicate_name.email = "new_email@new.com"
    user_with_duplicate_name.should_not be_valid
  end
  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

# PASSWORDS
  describe "password validations" do

    before(:each) do
      @user = User.new(@attr)   # NOT create -- don't want to save to database
    end

    it "should require a password" do
      set_password(@user, "").should_not be_valid
#      User.new(@attr.merge(:password => "", :password_confirmation => "")).should_not be_valid
    end

    it "should be valid with matching password and confirmation" do
      @user.should be_valid
#     User.new(@attr).should be_valid
    end
    
    it "should require a matching password confirmation" do
      set_password(@user, @user.password, "bogusword").should_not be_valid
    end

    it "should be invalid with blank password_confirmation" do
      set_password(@user, @user.password, "").should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      set_password(@user, short).should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      set_password(@user, long).should_not be_valid
    end

    it "should reject passwords containing the user name (case insensitive)" do
      set_password(@user, "ABC"+@user.name.upcase).should_not be_valid
    end
    
    it "should reject passwords containing the user email (case insensitive)" do
      set_password(@user, @user.email.upcase).should_not be_valid
      set_password(@user, @user.email.upcase[1..6]).should_not be_valid
    end

    it "should reject passwords containing only numbers" do
      set_password(@user, '123454382').should_not be_valid
    end

    it "should accept passwords with DOUBLE characters" do
      set_password(@user, 'bbcddffaa').should be_valid
    end

    it "should reject passwords containing repeated characters" do
      set_password(@user, 'bcdfaaaa').should_not be_valid
    end

  end # describe "password validations" do

  # PASSWORD ENCRYPTION
  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    it "should not store unencrypted password" do
      @user.encrypted_password.should_not == @user.password
    end

    describe "has_password? method" do

      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end    

      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end 
    end

    describe "authenticate method" do

      it "should return nil on username/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:name], "wrongpass")
        wrong_password_user.should be_nil
      end

      it "should return nil for an name with no user" do
        nonexistent_user = User.authenticate("Foo Bar", @attr[:password])
        nonexistent_user.should be_nil
      end

      it "should return the user on email/password match" do
        matching_user = User.authenticate(@attr[:name], @attr[:password])
        matching_user.should == @user
      end
    end # "authenticate method"
  end # PASSWORD ENCRYPTION

  describe "password integrity" do
  
    before :each do
      @u = User.create!(@attr)
      @hashed = @u.encrypted_password
      @user = User.find(@u.id)  # may be same as reload, but should clear passwords
    end
    
    it "updates password with mass assignment including password" do
      @user.update_attributes(:name=>'Newname', :password=>'NewPassword', 
                              :password_confirmation=>'NewPassword')
      @user.encrypted_password.should_not == @hashed
    end
    
    it "keeps password with mass assignment not including password" do
      @user.update_attributes(:name=>'Newname', :admin=>false, :medical=>true)
      @user.encrypted_password.should == @hashed
    end
    
    it "keeps password with update_attribute (skips validation)" do
      @user.update_attribute(:name,'Newname')
      @user.encrypted_password.should == @hashed
    end
    
  end

  describe "admin attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end

    it "cannot delete the last admin user" do
      @user.toggle!(:admin)
      @user.destroy.should be_false
    end
    

  end # "admin attribute" 

end

