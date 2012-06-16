require 'spec_helper'

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

  describe 'Edit' do
    it 'converts to_groups to array' do
      # NB: If this test fails because of an invalid 'message', you may get a Routing Error,
      #   No route matches {:controller=>"messages", :action=>"edit"
      # which is not helpful! That's why we do the message.should be_valid after creating it.
      message = Message.create(:to_groups=>"1,2", :body=>"Test", :send_email=>true)
      message.errors.should == {} 
#      Message.stub(:find).with(1).and_return(message)
      put :edit, :id=>message.id
      assigns(:record).to_groups.should == [1, 2]
    end
  end
  
  describe 'Create' do
    it 'adds user name to record' do
      post :create, :record => {:body=>"test", :to_groups=>["1", '2'], :send_email=>true}
      Message.first.user.should == @user
    end
  end
  
      

end
