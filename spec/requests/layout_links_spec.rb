require 'spec_helper'
  require "webrat"

  Webrat.configure do |config|
    config.mode = :rails
  end

describe "LayoutLinks" do

  describe "when not signed in" do
    it "should have a signin link" do
      visit root_path
      page.should have_selector("a", :href => signin_path,
                                         :content => "Sign in")
    end
  end

  describe "when signed in" do

    before(:each) do
      @user = Factory.create(:user)
      visit signin_path
      fill_in "Name",    :with => @user.name
      fill_in "Password", :with => @user.password
      click_button "Sign in"
    end

    it "should have a signout link" do
      visit root_path
# save_and_open_page( )
       page.should have_selector("a", :href => signout_path,
                                         :content => "Sign out")
    end

  end
end

