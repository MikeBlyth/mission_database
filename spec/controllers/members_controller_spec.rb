require 'spec_helper'
require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end

describe MembersController do
  render_views
  
  before(:each) do
    @user = Factory(:user)
    test_sign_in(@user)
  end

  describe "authentication before controller access" do

    describe "for non-signed-in users" do
      before(:each) {test_sign_out}

      it "should deny access to 'new'" do
        get :new
        response.should redirect_to(signin_path)
      end

      deny_edit
      deny_update
      deny_show
      deny_destroy
    end

  end # describe "authentication before controller access"

end
