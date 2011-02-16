require 'rubygems'
require 'spork'
#require 'capybara/rspec'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  
  require File.dirname(__FILE__) + "/factories"  

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    ### Part of a Spork hack. See http://bit.ly/arY19y
    # Emulate initializer set_clear_dependencies_hook in 
    # railties/lib/rails/application/bootstrap.rb
    ActiveSupport::Dependencies.clear
    
  end

  # Define a helper to directly sign in a test user
  def test_sign_in(user)
    controller.sign_in(user)
  end

  def test_sign_out
    controller.sign_out
  end

  def integration_test_sign_in
      @user = Factory.create(:user)
      visit signin_path
      fill_in "Name",    :with => @user.name
      fill_in "Password", :with => @user.password
      click_button "Sign in"
  end


end # Spork.prefork

Spork.each_run do
  # This code will be run each time you run your specs.
          # Default in most controller tests is for user to be signed in, since all views are protected. Test the protection by
        # signing out before this group of tests.
  def deny_all
    deny_edit
    deny_update
    deny_show
    deny_destroy
  end
    
  def deny_edit
    it "should deny access to 'edit'" do
      get :edit, :id => @user
      response.should redirect_to(signin_path)
    end
  end      

  def deny_update
    it "should deny access to 'update'" do
      put :update, :id => @user, :user => {}
      response.should redirect_to(signin_path)
    end
  end      

  def deny_show
    it "should deny access to 'show'" do
      get :show, :id => @user
      response.should redirect_to(signin_path)
    end
  end      

  def deny_destroy
    it "should deny access to 'destroy'" do
      put :destroy, :id => @user
      response.should redirect_to(signin_path)
    end
  end      

end


