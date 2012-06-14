require 'spec_helper'

describe SentMessage do
  describe 'send_to_gateways' do
    before(:each) do
      @member = Factory.build(:member)
      @contact = Factory.build(:contact)
      @member.stub(:primary_contact).and_return(@contact)
      Member.stub(:those_in_country).and_return([@member])
      ActionMailer::Base.deliveries.clear  # clear incoming mail queue
      @gw_msg_id = '74958a4f4c328c5bd4a988dfb5a0670c'
      @message = Message.new(:body=>'test message', :to_groups=>"1")
      @sent_message = SentMessage.new(:message=>@message, :member=>@member)
#      @sent_message = mock_model(SentMessage, {:message=>@message, :member=>@member}).as_null_object
      @email = mock('Email', :deliver=>true)
      Notifier ||= mock('Notifier', :send_generic => @email)
      @message.stub(:created_at).and_return(Time.now)
      @gateway = mock('gateway').as_null_object
      ClickatellGateway ||= mock('ClickatellGateway')
      ClickatellGateway.stub(:new).and_return(@gateway)
      end
    
    it "Sends an email" do
      @message.send_email = true
      Notifier.should_receive(:send_generic).with([@contact.email_1], @message.body)
      @sent_message.send_to_gateways
    end

    it "Sends an SMS but not email" do
      @message.send_sms = true
      @gateway.should_receive(:deliver)# .with(@contact.phone_1, "test message #{@message.timestamp}")
      Notifier.should_not_receive(:send_generic)
      @sent_message.send_to_gateways
    end

    it "Resends up to maximum retries" do
      @message.send_sms = true
      @message.retries = 1
      @gateway.should_receive(:deliver).with(@contact.phone_1, "test message #{@message.timestamp}").twice
      3.times {@sent_message.send_to_gateways}
      @sent_message.attempts.should == 2  # Original plus one retry
    end
    
    it "does not send email if email not specified" do  
      Notifier.should_not_receive(:send_generic)
      @sent_message.send_to_gateways
    end

    it "does not send email if email address not specified" do  
      @message.send_email = true
      @contact.email_1 = nil
      Notifier.should_not_receive(:send_generic)
      @sent_message.send_to_gateways
    end

    it "does not send SMS if SMS not specified" do  
      @gateway.should_not_receive(:deliver)
      @sent_message.send_to_gateways
    end

    it "does not send SMS if phone number not specified" do  
      @message.send_sms = true
      @contact.phone_1 = nil
      @gateway.should_not_receive(:deliver)
      @sent_message.send_to_gateways
    end

    it "sets the gateway message ID" do
      @gateway.stub(:deliver).and_return("ID: #@gw_msg_id")
      @message.send_sms = true
      @sent_message.should_receive(:update_attributes).with(:attempts=>1, :gateway_message_id=>@gw_msg_id)
      @sent_message.send_to_gateways
    end

  end    


end
