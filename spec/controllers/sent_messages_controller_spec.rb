require 'spec_helper'

describe SentMessagesController do
  before( :each) {test_sign_in_fast}

  describe "incoming Clickatell status updates" do
    before( :each) do
      @apiMsgId = '996f364775e24b8432f45d77da8eca47'
      @params = { :api_id => '12345',  :apiMsgId => @apiMsgId, :cliMsgId => 'abc123', 
      :timestamp => '1218007814', :to => '279995631564', :from => '27833001171', :status => '003', 
      :charge => '0.300000' }
      @sent_message = mock_model(SentMessage).as_null_object
      SentMessage.should_receive(:find_by_gateway_message_id).with(@apiMsgId).and_return(@sent_message)
    end
    
    it 'finds the right message to update' do
      get :update_status_clickatell, @params
    end
    
    it 'updates the message status' do
      @sent_message.should_receive(:update_attributes).with(hash_including(:status => anything()))
      get :update_status_clickatell, @params
    end

  end # incoming Clickatell status updates
        
end
