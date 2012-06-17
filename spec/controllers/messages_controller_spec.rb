require 'spec_helper'
require 'mock_clickatell_gateway'
require 'messages_test_helper'
include MessagesTestHelper

describe MessagesController do

      before(:each) do
        @user = Factory(:user, :admin=>true)
        test_sign_in(@user)
      end

  def mock_message(stubs={})
    @mock_message ||= mock_model(Message, stubs).as_null_object
  end

  describe 'New' do
    
    it 'sets defaults from Settings' do
      put :new
      settings_with_default = [:confirm_time_limit, :retries, :retry_interval, :expiration, 
                               :response_time_limit, :importance]
      settings_with_default.each {|setting| assigns(:record)[setting].should == Settings.messages[setting]}
    end
  end

  describe 'Create' do
    before(:each) do
      @old_applog = AppLog
      silence_warnings { AppLog = mock('AppLog') }
    end
    after(:each) do
      silence_warnings { AppLog = @old_applog }
    end
      
    it 'adds user name to record' do
      post :create, :record => {:body=>"test", :to_groups=>["1", '2'], :send_email=>true}
      Message.first.user.should == @user
    end
    
    it 'sends the message' do
      @members = members_w_contacts(1, false)
      AppLog.should_receive(:create)
      post :create, :record => {:body=>"test", :to_groups=>["1", '2'], :send_sms=>true}
    end  
  end
  
      

end
