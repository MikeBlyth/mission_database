require 'spec_helper'
require 'capybara/rspec'

#Webrat.configure do |config|
#  config.mode = :rails
#end

describe "LayoutLinks" do

  describe "when not signed in" do
    it "should have a signin but no signout or content link" do
      visit root_path
      page.should have_link("Sign in")
      page.should have_no_link("Sign out")
      page.should have_no_link("Families")
    end
  end # "when not signed in"

  describe "when signed in as ordinary user" do

    before(:each) {integration_test_sign_in(:admin=>false)}

    it "should have a signout and content link but no signin link" do
      visit root_path
      page.should have_link("Sign out")
      page.should have_link("Families")
      page.should have_no_link("Sign in")
    end

    it "should not have a link to add users" do
      visit root_path
      page.should have_no_link("Add User")
    end

  end # "when signed in as ordinary user"

  describe "when signed in as administrator" do

    before(:each) {integration_test_sign_in(:admin=>true)}

    it "should have a signout and content link but no signin link" do
      visit root_path
      page.should have_link("Sign out")
      page.should have_link("Families")
      page.should have_no_link("Sign in")
    end

    it "should have a link to add users" do
      visit root_path
      page.should have_link("Add User")
    end

  end # "when signed in as administrator"
end

