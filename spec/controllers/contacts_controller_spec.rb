require 'spec_helper'
require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end

describe ContactsController do
  render_views

  before(:each) do
    @member = Factory(:family).head
    @contact = Factory(:contact, :member=>@member)
  end

  # Check that access to controller is blocked when user is not logged in (use deny_access method defined in spec_helper)
  # "authentication before controller access"
  describe "authentication before controller access" do

    describe "for signed-in users" do
 
      before(:each) do
        @user = Factory(:user)
        test_sign_in(@user)
      end
      
      it "should allow access to 'new'" do
        Contact.should_receive(:new)
        get :new
      end

      it "should allow access to 'edit'" do
        get :edit, :id => @contact.id
        response.should_not redirect_to(signin_path)
      end

      it "should allow access to 'show'" do
        get :show, :id => @contact.id
        response.should_not redirect_to(signin_path)
      end

      it "should allow access to 'destroy'" do
        put :destroy, :id => @contact.id
        response.should_not redirect_to(signin_path)
      end
      
      it "should allow access to 'update'" do
        # Member.should_receive(:update)
        put :update, :id => @contact.id, :record => @contact.attributes
        response.should_not redirect_to(signin_path)
      end
      
    end # for signed-in users

    describe "for non-signed-in users" do
      before(:each) {test_sign_out}

      it "should deny access to 'new'" do
        get :new
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'edit'" do
        get :edit, :id => @contact.id
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @contact.id, :record => @contact.attributes
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'show'" do
        get :show, :id => @contact.id
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'destroy'" do
        put :destroy, :id => @contact.id
        response.should redirect_to(signin_path)
      end

#      deny_edit
#      deny_update
#      deny_show
#      deny_destroy
    end

  end # describe "authentication before controller access"

end
