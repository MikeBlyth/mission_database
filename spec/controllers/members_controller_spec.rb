require 'spec_helper'
require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end

describe MembersController do
  
  before(:each) do
    @family = Factory(:family)
    @member = @family.head
    Factory(:country_unspecified)
  end

  describe "authentication before controller access" do

    describe "for signed-in users" do
 
      before(:each) do
        @user = Factory(:user)
        test_sign_in(@user)
      end
      
      it "should allow access to 'new'" do
        Member.should_receive(:new)
        get :new
      end
      
      it "should allow access to 'destroy'" do
        # Member.should_receive(:destroy) # Why can't this work ??
        put :destroy, :id => @member.id
        response.should_not redirect_to(signin_path)
      end
      
      it "should allow access to 'update'" do
        # Member.should_receive(:update)
        put :update, :id => @member.id, :record => @member.attributes, :member => @member.attributes
        response.should_not redirect_to(signin_path)
      end
      
    end # for signed-in users

    describe "for non-signed-in users" do

      it "should deny access to 'new'" do
        get :new
        response.should redirect_to(signin_path)
      end

    end # for non-signed-in users

  end # describe "authentication before controller access"

end
