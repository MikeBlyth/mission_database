require 'spec_helper'
#require "webrat"

#Webrat.configure do |config|
#  config.mode = :rails
#end

describe "Users" do
  describe "Administrator Add User" do

    before(:each) { integration_test_sign_in(:admin=>true)}

    describe "failure" do

      it "should not create a new user with missing values" do
        lambda do
          visit new_user_path
          fill_in "Name",         :with => ""
          fill_in "Email",        :with => ""
          fill_in "Password",     :with => ""
          fill_in "Confirmation", :with => ""
          click_button "Create"
          page.should have_content("Email can't be blank")
          page.should have_content("Name can't be blank")
          page.should have_content("Email is invalid")
          page.should have_content("Password can't be blank")
          page.should have_content("too short")
        end.should_not change(User, :count)
      end
    end

    describe "success" do

      it "should create a new user with good values" do
        lambda do
          visit new_user_path
          fill_in "Name",         :with => "Example User"
          fill_in "Email",        :with => "user@example.com"
          fill_in "Password",     :with => "foobar"
          fill_in "Confirmation", :with => "foobar"
          click_button "Create"
          page.should have_selector("div.flash.success",
                                        :content => "Successfully")
        end.should change(User, :count).by(1)
      end
    end # Describe success
  end # Describe Administrator add user

  describe "Non-administrator Add User" do
    before(:each) { integration_test_sign_in(:admin=>false)}

    it "should not create a new user even with good values" do
      visit new_user_path
      page.should have_selector("title", :content => "SIM")
      page.should have_selector("div.flash.error")
    end
  end # "Non-administrator Add User"

  describe "sign in/out" do

    describe "failure" do
      it "should not sign a user in with missing values" do
        visit signin_path
        fill_in "Name",    :with => ""
        fill_in "Password", :with => ""
        click_button "Sign in"
        page.should have_selector("div.flash.error", :content => "Invalid")
      end
    end

    describe "success" do
      it "should sign a user in and out with right values" do
       user = Factory(:user)
        visit signin_path
        fill_in "Name",    :with => user.name
        fill_in "Password", :with => user.password
        click_button "Sign in"
        page.should have_selector("a", :content => "Sign out")
        click_link "Sign out"
        page.should have_selector("a", :content => "Sign in")
      end
    end
  end

end
