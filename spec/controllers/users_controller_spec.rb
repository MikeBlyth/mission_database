require 'spec_helper'
require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end

describe UsersController do
  render_views
  
  before(:each) do
    @user = Factory(:user)
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
    it "should have the right title" do
      get 'new'
      response.should have_selector("title", :content => "Sign up")
    end
    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
  end

end
