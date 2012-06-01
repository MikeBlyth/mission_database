require 'spec_helper'

describe FieldTermsController do
  
  before(:each) do
  end

  describe 'Export' do
      before(:each) do
        @user = Factory(:user, :admin=>true)
        test_sign_in(@user)
      end
    
    it 'CSV sends data file' do
      get :export
      response.headers['Content-Disposition'].should include("filename=\"field_terms.csv\"")
    end
  end # Export
     
end
