require 'spec_helper'
require 'sms_controller.rb'
require 'sms_gateway.rb'
require 'fakeweb.rb'

describe TwilioGateway do

  before(:each) do
    AppLog.stub(:create)
    FakeWeb.register_uri(:any, %r/http:\/\/api.twilio.com\//, :body => '{"message": "You tried to reach Twilio"}')
    @phone_1, @phone_2 = '+2347777777777', '+2348888888888'
  end

  describe 'initialization' do

    it 'gives error when parameter is missing' do
      SiteSetting.stub(:twilio_account_sid).and_return(nil)  # Make User_name missing BEFORE .new
      @gateway = TwilioGateway.new
      @gateway.errors.should_not be_nil  # Will have errors even before saving 
      @gateway.errors[0].should match('account_sid')
    end

    it 'initializes successfully when needed parameters are present' do
      @gateway = TwilioGateway.new
      if @gateway.errors
        puts "*** Maybe the settings database has not been initialized."
        puts "*** Errors in gateway initialization may also be caused by 'cleaned' initialization"
        puts "*** parameters. Try restarting Spork before looking for other errors."
      end
      @gateway.errors.should be_nil
      @gateway.gateway_name.should == 'twilio'  # this is defined by TwilioGateway#initialize
    end
    
  end # initialization

  describe 'twilio-ruby @client connects to http' do
    it 'with basic authentication' do
#      HTTParty.should_receive(:get).with(test_uri) # i.e. without getting a session
#      HTTParty.should_not_receive(:get).with(/auth?/)
      @gateway = TwilioGateway.new
      @gateway.deliver(["99"],'Test message')
      rq = FakeWeb.last_request.body
      rq.should match("To=%2b99")
      rq.should match("Body=Test%20message")
    end
  end

 
#  describe 'Queries status of a message' do
#    before(:each) do 
#      gateway_session_set('dummy')
#      @msg_id = 'abc'
#    end
#    
#    it 'Returns status when Twilio gives it' do
#      msg_id = "abcdefg12"
#      target = Regexp.new("querymsg\\?apimsgid=abcdefg12")  # 
#      @mock_reply.stub(:body).and_return "ID: #{msg_id} Status: 004"
#      HTTParty.should_receive(:get).with(target).and_return(@mock_reply)
#      @gateway.query(msg_id).should == MessagesHelper::MsgDelivered
#    end
#    
#    it 'Returns error message when Twilio rejects query' do
#      msg_id = "abcdefg12"
#      target = Regexp.new("querymsg\\?apimsgid=abcdefg12")  # 
#      error_message = "Err: 009, Some Error"
#      @mock_reply.stub(:body).and_return error_message
#      HTTParty.should_receive(:get).with(target).and_return(@mock_reply)
#      @gateway.query(msg_id).should == error_message
#    end
#    
#  end
      
  describe 'Deliver method sends messages' do
    before(:each) do
#      @client = Twilio::REST::Client.new "@account_sid", "auth_token"
      @client = mock('Client').as_null_object
      Twilio::REST::Client.stub(:new => @client)
      @gateway = TwilioGateway.new
      @body = 'Test message'
    end

    describe 'for single phone number' do
      before(:each) do
        @phones = [@phone_1]
      end
      
      it 'calls @client to send message' do
        @client.should_receive(:create).with(hash_including(:from => SiteSetting.twilio_phone_number, :to => @phones[0], :body => @body))
        @gateway.deliver(@phones, @body)
      end

      it "adds + to a phone number" do
        @client.should_receive(:create).with(hash_including(:from => SiteSetting.twilio_phone_number, :to => @phones[0], :body => @body))
        @gateway.deliver(@phones[0][1..20], @body)
      end

# These need to be redone after deciding how to manage return status of gateway objects
#      it 'sets @gateway_reply variable' do
#        @gateway.deliver(@phones, 'test message')
#        @gateway.gateway_reply.should == @mock_reply
#      end        

#      it 'gives @gateway_reply as return value' do
#        @gateway.deliver(@phones, 'test message').should == @mock_reply
#      end        

    end # for single phone number

    describe 'for multiple phone numbers' do
      before(:each) do
        @phones = [@phone_1, @phone_2]
      end

      it 'calls @client to send message' do
        @client.should_receive(:create).with(hash_including(:from => SiteSetting.twilio_phone_number, :to => @phones[0], :body => @body))
        @client.should_receive(:create).with(hash_including(:to => @phones[1], :body => @body))
        @gateway.deliver(@phones, @body)
      end

#      it 'forms URI phone list from string' do
#        @gateway.deliver(@phones.join(', '), 'test message')
#        uri = @gateway.uri
#        uri.should match("to=2347777777777,2348888888888")
#      end

#      it 'sets @gateway_reply variable' do
#        @gateway.deliver(@phones, 'test message')
#        @gateway.gateway_reply.should == @mock_reply
#      end        

#      it 'gives @gateway_reply as return value' do
#        @gateway.deliver(@phones, 'test message').should == @mock_reply
#      end        

    end # for multiple phone number

    describe 'handles errors' do

      it 'logs an error' do
        @phones = [@phone_1]
        @client.should_receive(:create).and_raise
        AppLog.should_receive(:create).with(hash_including(:code => "SMS.error.twilio"))
        @gateway.deliver(@phones, @body)
      end

      it 'continues after an error' do
        @phones = [@phone_1, @phone_2 ]
        @client.should_receive(:create).and_raise
        @client.should_receive(:create).with(hash_including(:to => @phone_2))
        AppLog.should_receive(:create).with(hash_including(:code => "SMS.error.twilio"))
        AppLog.should_receive(:create).with(hash_including(:code => "SMS.sent.twilio"))
        @gateway.deliver(@phones, @body)
      end

    end # handles errors

  end # deliver method
end
