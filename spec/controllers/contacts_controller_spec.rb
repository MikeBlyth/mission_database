require 'spec_helper'
include SimTestHelper

describe ContactsController do
  
  before(:each) do
      @user = Factory.stub(:user, :admin=>true)
      test_sign_in(@user)
  end

  describe 'Export' do
      before(:each) do
        @user = Factory(:user, :admin=>true)
        test_sign_in(@user)
      end
    
    it 'CSV sends data file' do
      get :export
      response.headers['Content-Disposition'].should =~ /contact.*csv/
    end
  end # Export
     
end
