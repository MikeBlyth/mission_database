require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

puts "SPORK PREFORK ..."

  require File.dirname(__FILE__) + "/factories"  

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'
# require 'spork/ext/ruby-debug'

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
  end   # Rspec.configure

  # Define a helper to directly sign in a test user
  def test_sign_in(user)
    controller.sign_in(user)
  end

  def test_sign_in_fast
      controller.stub(:authenticate_admin).and_return(:true)
      controller.stub(:authenticate).and_return(:true)
  end

  def test_sign_out
    controller.sign_out
  end

  def integration_test_sign_in(options={})
      @user = Factory.create(:user, options)
      visit signin_path
      fill_in "Name",    :with => @user.name
      fill_in "Password", :with => @user.password
      click_button "Sign in"
  end

#  require 'cover_me'  # This is for CoverMe code coverage

  # This line is ONLY needed when tests require the full set of tables (countries, locations, and so on) found
  # in seeds.rb. It takes a long time to run seeds, so it should not be included in ordinary testing.
  #  require "#{Rails.root}/db/seeds.rb"  
 

end # Spork.prefork

Spork.each_run do
puts "SPORK EACH_RUN ..."
#>  load Rails.root+'app/helpers/application_helper.rb'
  # This code will be run each time you run your specs.
          # Default in most controller tests is for user to be signed in, since all views are protected. Test the protection by
        # signing out before this group of tests.

end # Spork.each_run


