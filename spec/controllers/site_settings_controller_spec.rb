require 'spec_helper'

describe SiteSettingsController do
  before(:each) {test_sign_in_fast}
  
  it 'opens editing page' do
    get :edit
    response.should render_template("edit")
  end
  
  it 'updates values' do
    put :update, :birthday_prefix => "new prefix"
    SiteSetting[:birthday_prefix].should == "new prefix"
  end
  
  it 'gives flash notice on update' do
    put :update, :birthday_prefix => "new prefix"
    flash[:notice].should =~ /saved/i    
  end
end
