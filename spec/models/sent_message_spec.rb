require 'spec_helper'

describe SentMessage do
  describe 'send_to_gateways' do
    before(:each) do
      @old_notifier = Notifier
      @email = mock('Email', :deliver=>true)
      silence_warnings{ Notifier = mock('Notifier', :send_generic => @email) }
    end
    
    after(:each) do
      silence_warnings{ Notifier=@old_notifier }
    end
      
    before(:each) do
      @member = Factory.stub(:member)
      @contact = Factory.stub(:contact)
      @member.stub(:primary_contact).and_return(@contact)
      Member.stub(:those_in_country).and_return([@member])
      @gw_msg_id = '74958a4f4c328c5bd4a988dfb5a0670c'
      @gw_reply = "ID: #{@gw_msg_id}"
      @message = mock_model(Message, :body=>'test message', :to_groups=>"1", :send_email => true,
        :retries=>0, :send_email=>nil, :send_sms=>nil).as_null_object
      @sent_message = SentMessage.new(:message=>@message, :member=>@member)
      @message.stub(:timestamp).and_return('09Jul0545p')
      @gateway = mock('gateway', :deliver=>@gw_reply, :http_status=>@gw_reply).as_null_object
      ClickatellGateway ||= mock('ClickatellGateway')
      ClickatellGateway.stub(:new).and_return(@gateway)
      end
    
    it "Sends an email" do
      @message.stub(:send_email).and_return(true)
      Notifier.should_receive(:send_generic).with([@contact.email_1], @message.body)
      @sent_message.send_to_gateways
    end

    it "Sends an SMS but not email" do
      @message.stub(:send_sms).and_return(true)
      @gateway.should_receive(:deliver)# .with(@contact.phone_1, "test message #{@message.timestamp}")
      Notifier.should_not_receive(:send_generic)
      @sent_message.send_to_gateways
    end

    it "Resends up to maximum retries" do
      @message.stub(:send_sms).and_return(true)
      @message.stub(:retries).and_return(1)
      @gateway.should_receive(:deliver).with(@contact.phone_1, "test message #{@message.timestamp}").twice
      3.times {@sent_message.send_to_gateways}
      @sent_message.attempts.should == 2  # Original plus one retry
    end
    
    it "does not send email if email not specified" do  
      Notifier.should_not_receive(:send_generic)
      @sent_message.send_to_gateways
    end

    it "does not send email if email address not specified" do  
      @message.stub(:send_email).and_return(true)
      @contact.email_1 = nil
      Notifier.should_not_receive(:send_generic)
      @sent_message.send_to_gateways
    end

    it "does not send SMS if SMS not specified" do  
      @gateway.should_not_receive(:deliver)
      @sent_message.send_to_gateways
    end

    it "does not send SMS if phone number not specified" do  
      @message.stub(:send_sms).and_return(true)
      @contact.phone_1 = nil
      @gateway.should_not_receive(:deliver)
      @sent_message.send_to_gateways
    end

    it "sets the gateway message ID" do
      @message.stub(:send_sms).and_return(true)
      @sent_message.should_receive(:update_attributes).with(:attempts=>1, :gateway_message_id=>@gw_msg_id)
      @sent_message.send_to_gateways
    end

  end    


end
