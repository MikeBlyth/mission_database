require 'spec_helper'
require 'sim_test_helper'
require "webrat"
#include SimTestHelper

Webrat.configure do |config|
  config.mode = :rails
end

describe FieldTermsController do
  render_views
  
  before(:each) do
#    @user = Factory(:user)
#    test_sign_in(@user)
    @family = Factory(:family)
    @member = @family.head
    @contact = Factory(:contact, :member => @member)
    @travel = Factory(:travel, :member => @member)
    @field_term = Factory(:field_term, :member => @member)
  end

  # Check that access to controller is blocked when user is not logged in (use deny_access method defined in spec_helper)
  # "authentication before controller access"
  describe "authentication before controller access" do

    describe "for non-signed-in users" do
#      before(:each) {test_sign_out}

      it "should deny access to 'new'" do
        get :new
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'destroy'" do
        get :destroy, :id => @field_term.id
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'edit'" do
        get :edit, :id => @field_term.id
        response.should redirect_to(signin_path)
      end

 #     deny_edit
 #     deny_update
 #     deny_show
 #     deny_destroy
    end

  end # describe "authentication before controller access"

end
