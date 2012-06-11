require 'spec_helper'

describe SentMessage do
  describe 'send_to_gateways' do
    before(:each) do
      @member = Factory.build(:member)
      @contact = Factory.build(:contact)
      @member.stub(:primary_contact).and_return(@contact)
      ActionMailer::Base.deliveries.clear  # clear incoming mail queue
      @message = Message.new(:body=>'test message', :to_groups=>"1")
      @sent_message = SentMessage.new(:message=>@message, :member=>@member)
      @gateway = mock('gateway')
      ClickatellGateway ||= mock('ClickatellGateway')
      ClickatellGateway.stub(:new).and_return(@gateway)
    end
    
    it "Sends an email" do
      @message.send_email = true
      lambda{@sent_message.send_to_gateways}.should change(ActionMailer::Base.deliveries, :length).by(1)
    end

    it "Sends an SMS" do
      @message.send_sms = true
      @gateway.should_receive(:deliver).with(@contact.phone_1, 'test message')
      @sent_message.send_to_gateways
      puts "**** @sent_message.attributes=#{@sent_message.attributes}"
    end

    it "Resends up to maximum retries" do
      @message.send_sms = true
      @message.retries = 1
      @gateway.should_receive(:deliver).with(@contact.phone_1, 'test message').twice
      3.times {@sent_message.send_to_gateways}
      @sent_message.attempts.should == 2  # Original plus one retry
    end
    
    it "does not send email if email not specified" do  
      lambda{@sent_message.send_to_gateways}.should_not change(ActionMailer::Base.deliveries, :length)
    end

    it "does not send email if email not specified" do  
      @message.send_email = true
      @contact.email_1 = nil
      lambda{@sent_message.send_to_gateways}.should_not change(ActionMailer::Base.deliveries, :length)
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

  end    

end
