require 'spec_helper'
require '~/simjos/spec/support/mock_clickatell_gateway'
require '~/simjos/spec/support/messages_test_helper'
include MessagesTestHelper
include SimTestHelper

describe MessagesController do

      before(:each) do
        @user = Factory(:user, :admin=>true)
        test_sign_in(@user)
      end

  def mock_message(stubs={})
    @mock_message ||= mock_model(Message, stubs).as_null_object
  end

  describe 'New' do
    
    it 'sets user signature' do
      put :new
      assigns(:record)[:body].should match("from #{@user.name}")
      assigns(:record)[:sms_only].should match("#{@user.name}")
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
      post :create, :record => {:sms_only=>"test "*10, :to_groups=>["1", '2'], :send_sms=>true}
    end  
    
    it 'counts empty response_time_limit as nil' do
      AppLog.should_receive(:create)
      post :create, :record => {:sms_only=>"test "*10, :to_groups=>["1", '2'], 
        :response_time_limit=>'', :send_sms=>true}
      Message.first.response_time_limit.should == nil
    end
  end
  
  describe 'Follow up' do

    it 'sends the follow-up msg to those not responding to first msg' do  # Would be nice to do this w/o accessing DB!
      @gateway = mock('Gateway')
      MockClickatellGateway.stub(:new => @gateway)
      @original_msg = Factory(:message,:send_email => true)
      @fast_responder = Factory(:contact).member  # handy if not most efficient way to make a member with a contact
      @slow_responder = Factory(:contact).member
      @original_msg.members << [@fast_responder, @slow_responder]
      @fast_responder.sent_messages.first.update_attributes(:msg_status => MessagesHelper::MsgResponseReceived)
      @original_msg.members.should =~ [@fast_responder, @slow_responder]
      Notifier.should_receive(:send_group_message).
          with(hash_including(:recipients => [@slow_responder.primary_email],
                              :id => @original_msg.id)).
          and_return(mock('MailMessage').as_null_object)
      @gateway.should_receive(:deliver).with(anything(), Regexp.new(@original_msg.id.to_s))
      get :followup_send, :id => @original_msg.id, 
        :record => {:body=>"reminder",  :sms_only => '#'*50, :send_email => true, :send_sms => true}
    end    

  end                        

end
